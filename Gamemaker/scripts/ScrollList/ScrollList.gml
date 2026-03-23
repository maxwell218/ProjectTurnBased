// +-----------------------------------------------------------+
// |                                                           |
// |   ______   ______   ______   ______   __       __         |
// |  /\  ___\ /\  ___\ /\  == \ /\  __ \ /\ \     /\ \        |
// |  \ \___  \\ \ \____\ \  __< \ \ \/\ \\ \ \____\ \ \____   |
// |   \/\_____\\ \_____\\ \_\ \_\\ \_____\\ \_____\\ \_____/  |
// |    \/_____/ \/_____/ \/_/ /_/ \/_____/ \/_____/ \/_____/  |
// |                                                           |
// +-----------------------------------------------------------+
// class.ScrollList

enum ScrollAxis {
    Vertical,
    Horizontal
}
enum ScrollListPart {
    Thumb,
    Scrollbar
}
enum ScrollListBorderStyle {
    Shared, // Items in the list share the same borders
    Split,  // Each item in the list have their own set of borders
}
enum ScrollListSizeMode {
    ShrinkContent, // List size is fixed, items shrink by scrollbar_thickness when bar appears
    PushContent,    // Item area is fixed, list grows by scrollbar_thickness when bar appears, marks parent layout dirty
}

function ScrollList(_config) : UIParent(_config) constructor {
    var _self = self;

    #region Config
	
	// Public
	static get_content_size = function() {
	    var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
	    var _w = __.width;
	    var _h = __.height;
	    if (__.size_mode == ScrollListSizeMode.PushContent && __.scrollbar_needed) {
	        if (_is_vertical) {
	            _w += __.scrollbar_thickness;
	        } else {
	            _h += __.scrollbar_thickness;
	        }
	    }
	    return { width: _w, height: _h };
	}

    // Private
    with (__) {
        // Scroll axis
        scroll_axis = _config[$ "scroll_axis"] ?? ScrollAxis.Vertical;

        // Size mode
        size_mode = _config[$ "size_mode"] ?? ScrollListSizeMode.ShrinkContent;

        // Padding
        padding      = _config[$ "padding"] ?? 0;
        border_style = (padding > 0) ? ScrollListBorderStyle.Split : ScrollListBorderStyle.Shared;

        // Scroll behaviour
        scroll        = 0;
        scroll_target = 0;
        scroll_lerp   = _config[$ "scroll_lerp" ] ?? 0.1;
        scroll_speed  = _config[$ "scroll_speed"] ?? 20;

        // Scrollbar appearance
		scrollbar_needed	= false;
        scrollbar_color     = _config[$ "scrollbar_color"    ] ?? COLORS.col_green_dark;
        scrollbar_thickness = _config[$ "scrollbar_thickness"] ?? 5;
        scrollbar_padding   = _config[$ "scrollbar_padding"  ] ?? 1;
        scrollbar_thumb_min = _config[$ "scrollbar_thumb_min"] ?? 20;
        scrollbar_selected  = false;

        // Background
        bg_color    = _config[$ "bg_color"   ] ?? c_dkgray;
        line_height = _config[$ "line_height"] ?? 8;

        // Content / surface
        content_size  = 0;
        surface       = -1;

        // Overflow state — used by PushContent to detect changes
        has_scrollbar = false;

        // Visible-child culling
        child_draw_start  = 0;
        child_draw_amount = 0;

        // Pseudo-elements for thumb / track hover tracking
        pseudo_elements = array_create(2, undefined);
        pseudo_elements[ScrollListPart.Thumb]     = { name: "Thumb",     owner: _self, is_hovered: false, get_is_hovered: function() { return is_hovered }, set_is_hovered: function(_is_hovered) { is_hovered = _is_hovered } };
        pseudo_elements[ScrollListPart.Scrollbar] = { name: "Scrollbar", owner: _self, is_hovered: false, get_is_hovered: function() { return is_hovered }, set_is_hovered: function(_is_hovered) { is_hovered = _is_hovered } };
    }

    #endregion
    #region Init

    // Public
    static init = function() {
        __.scrollbar_selected = false;
        __.scroll_target      = 0;
        __.scroll             = 0;

        // TODO: Replace placeholder item construction with injected content
        var _count = array_length(__.children);
        array_delete(__.children, 0, _count);

        for (var _i = 0; _i < _count; _i++) {
            var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
            var _item_main   = 72;

            // Cross axis is always the full list dimension on init —
            // rebuild_content will adjust based on size_mode
            var _item_cross = (_is_vertical ? __.width : __.height) - __.padding * 2;

            var _config = {
                x:      0,
                y:      0,
                width:  _is_vertical ? (_item_cross - 1) : (_item_main - 1),
                height: _is_vertical ? (_item_main  - 1) : (_item_cross - 1),
                item:   "Item " + string(_i),
            };

            var _item = new ScrollListItem(_config);
            array_push(__.children, _item);
        }

        rebuild_content();
    }

    #endregion
    #region Resize

    // Public
    static resize = function(_config) {
        __.x = _config[$ "x"] ?? __.x;
        __.y = _config[$ "y"] ?? __.y;

        __.width  = _config[$ "width" ] ?? __.width;
        __.height = _config[$ "height"] ?? __.height;

        rebuild_content();
    }

    #endregion
    #region Step

    // Public
    static step = function() {
        var _is_vertical  = (__.scroll_axis == ScrollAxis.Vertical);
        var _view_size    = _is_vertical ? __.height : __.width;
        var _content_size = __.content_size;

        // --- Scrollbar drag ---
        if (__.scrollbar_selected) {
            var _local_pos  = _is_vertical
                              ? (obj_cursor.gui_y - __.y)
                              : (obj_cursor.gui_x - __.x);

            // TODO: On scrollbar selected, record cursor position
            var _thumb_size = __get_thumb_size();
            var _track_size = _view_size - _thumb_size;

            _local_pos = clamp(_local_pos - (_thumb_size * 0.5), 0, _track_size);

            __.scroll_target = _local_pos / _track_size * (_content_size - _view_size);
        }

        // Clamp + smooth
        __.scroll_target = clamp(__.scroll_target, 0, max(0, _content_size - _view_size));
        __.scroll        = lerp(__.scroll, __.scroll_target, __.scroll_lerp);

        // --- Child culling along the main axis ---
        var _top_view    = __.scroll;
        var _bottom_view = __.scroll + _view_size;
        var _count       = array_length(__.children);

        var _i = 0;
        while (_i < _count) {
            var _item     = __.children[_i];
            var _item_end = _is_vertical ? (_item.get_y() + _item.get_height()) : (_item.get_x() + _item.get_width());
            if (_item_end >= _top_view) break;
            _i++;
        }
        __.child_draw_start = _i;

        while (_i < _count) {
            var _item       = __.children[_i];
            var _item_start = _is_vertical ? _item.get_y() : _item.get_x();
            if (_item_start > _bottom_view) break;
            _i++;
        }
        __.child_draw_amount = _i - __.child_draw_start;
    }

    #endregion
    #region Input

    // Public
    static on_primary_action_pressed = function() {
        if (__.pseudo_elements[ScrollListPart.Thumb].is_hovered
        ||  __.pseudo_elements[ScrollListPart.Scrollbar].is_hovered) {
            __.scrollbar_selected = true;
            event_manager_publish(Event.CaptureActiveElement, self);
        }
    }
    static on_primary_action_released = function() {
        if (__.scrollbar_selected) {
            __.scrollbar_selected = false;
            event_manager_publish(Event.UnsetActiveElement);
        }
    }
    static on_scroll = function() {
        var _mw = mouse_wheel_up() - mouse_wheel_down();
        if (!__.scrollbar_selected && __.is_hovered) {
            __.scroll_target -= _mw * __.scroll_speed;
        }
    }

    #endregion
    #region Rebuild

    // Public
    static rebuild_content = function() {
        var _is_vertical    = (__.scroll_axis == ScrollAxis.Vertical);
        var _count          = array_length(__.children);
        var _border_offset  = (__.border_style == ScrollListBorderStyle.Shared) ? 1 : 0;
        var _cursor         = __.padding;

        // --- Pass 1: Measure ---
        // Position children along the main axis, compute total content_size.
        // Cross-axis size is set here based on size_mode — ShrinkContent starts
        // at full width and may shrink in pass 2, PushContent
        // set their final cross-axis size now and never change it.

        var _cross_size = _is_vertical ? __.width : __.height;

        switch (__.size_mode) {
            case ScrollListSizeMode.ShrinkContent:
                // Items start at full cross size, may shrink in pass 2 if overflow detected
                _cross_size = (_is_vertical ? __.width : __.height) - __.padding * 2;
                break;
            case ScrollListSizeMode.PushContent:
                // Items always take full cross size — list grows outward if bar appears
                _cross_size = (_is_vertical ? __.width : __.height) - __.padding * 2;
                break;
        }

        for (var _i = 0; _i < _count; _i++) {
            var _item = __.children[_i];
            if (_is_vertical) {
                _item.set_x(__.padding);
                _item.set_y(_cursor);
                _item.set_width(_cross_size - 1);
                _cursor += _item.get_height() + __.padding + 1;
            } else {
                _item.set_x(_cursor);
                _item.set_y(__.padding);
                _item.set_height(_cross_size - 1);
                _cursor += _item.get_width() + __.padding + 1;
            }
        }

        var _view_size		= _is_vertical ? __.height : __.width;
        __.content_size		= max(_cursor + _border_offset, _view_size);
        __.scrollbar_needed = (__.content_size > _view_size);

        // --- Pass 2: Overflow ---
        // Handle scrollbar consequence per size_mode

        switch (__.size_mode) {
            case ScrollListSizeMode.ShrinkContent:
                // Shrink items on the cross axis to make room for the scrollbar
                if (__.scrollbar_needed) {
                    for (var _i = 0; _i < _count; _i++) {
                        var _item = __.children[_i];
                        if (_is_vertical) {
                            _item.set_width(_item.get_width() - __.scrollbar_thickness);
                        } else {
                            _item.set_height(_item.get_height() - __.scrollbar_thickness);
                        }
                    }
                }
                break;
	        case ScrollListSizeMode.PushContent:
				// PushContent case — notify layout if overflow state changed
	            if (__.scrollbar_needed != __.has_scrollbar) {
	                __.has_scrollbar = __.scrollbar_needed;
	            }
	            break;
        }
    }

    #endregion
    #region Render

    // Public
    static render = function() {
        var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
        var _view_size   = _is_vertical ? __.height : __.width;

        if (!surface_exists(__.surface)) {
            __.surface = surface_create(__.width, __.height);
        }

        surface_set_target(__.surface);
        draw_clear_alpha(c_black, 0);

        draw_set_color(__.bg_color);
        draw_rectangle(0, 0, __.width, __.height, false);

        var _context = {
            scroll_axis: __.scroll_axis,
            scroll_x:    (__.scroll_axis == ScrollAxis.Horizontal) ? __.scroll : 0,
            scroll_y:    (__.scroll_axis == ScrollAxis.Vertical)   ? __.scroll : 0,
            border_style: __.border_style,
        };

        var _hovered_child = undefined;

        for (var _i = __.child_draw_start; _i < __.child_draw_start + __.child_draw_amount; _i++) {
            var _child = __.children[_i];
            _child.render(_context);

            if (_hovered_child == undefined && _child.get_is_hovered()) {
                _hovered_child = _child;
            }
        }

        if (_hovered_child != undefined && UI_MANAGER.get_active_element() == undefined) {
            _hovered_child.render_hover(_context);
        }

        // Scrollbar — rendered when overflowed
        var _render_scrollbar = __.scrollbar_needed;

        if (_render_scrollbar) {
            var _thumb_size = __get_thumb_size();
            var _thumb_pos  = (__.content_size > _view_size)
                              ? (__.scroll / (__.content_size - _view_size) * (_view_size - _thumb_size))
                              : 0;
            var _sb_padding = __.scrollbar_padding;
            _thumb_pos = clamp(_thumb_pos, _sb_padding, _view_size - _thumb_size - _sb_padding - 1);

            if (_is_vertical) {
                var _sx = __.width - __.scrollbar_thickness;
                draw_set_color(c_olive);
                draw_rectangle(_sx, 0, __.width, __.height, false);
                if (__.content_size > _view_size) {
                    draw_set_color(
                        (__.scrollbar_selected || __.pseudo_elements[ScrollListPart.Thumb].is_hovered)
                        ? c_white : __.scrollbar_color
                    );
                    draw_rectangle(
                        _sx + _sb_padding,
                        _thumb_pos,
                        __.width - _sb_padding - 1,
                        _thumb_pos + _thumb_size,
                        false
                    );
                }
            } else {
                var _sy = __.height - __.scrollbar_thickness;
                draw_set_color(c_olive);
                draw_rectangle(0, _sy, __.width, __.height, false);
                if (__.content_size > _view_size) {
                    draw_set_color(
                        (__.scrollbar_selected || __.pseudo_elements[ScrollListPart.Thumb].is_hovered)
                        ? c_white : __.scrollbar_color
                    );
                    draw_rectangle(
                        _thumb_pos,
                        _sy + _sb_padding,
                        _thumb_pos + _thumb_size,
                        __.height - _sb_padding - 1,
                        false
                    );
                }
            }
        }

        draw_set_color(c_white);
        surface_reset_target();
        draw_surface(__.surface, __.x, __.y);
    }
    static render_gui = function() {
        if (global.debug) {
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_text(__.x, __.y + __.height, "scroll = " + string(__.scroll));
            draw_text(__.x, __.y + __.height + __.line_height, "content_size = " + string(__.content_size));
        }
    }

    #endregion
    #region Hover

    // Public
    static collect_hover_inherited = UIParent.collect_hover;
    static collect_hover = function(_mouse_x, _mouse_y, _hovered_stack) {
        if (__is_hover_thumb(_mouse_x, _mouse_y)) {
            array_push(_hovered_stack, __.pseudo_elements[ScrollListPart.Thumb]);
        }
        if (__is_hover_scrollbar(_mouse_x, _mouse_y)) {
            array_push(_hovered_stack, __.pseudo_elements[ScrollListPart.Scrollbar]);
        }
        var _context = {
            scroll_x:  (__.scroll_axis == ScrollAxis.Horizontal) ? __.scroll : 0,
            scroll_y:  (__.scroll_axis == ScrollAxis.Vertical)   ? __.scroll : 0,
            surface_x: __.x,
            surface_y: __.y,
        };
        return collect_hover_inherited(_mouse_x, _mouse_y, _hovered_stack, _context);
    }

    // Private
    with (__) {
        static __is_hover_scrollbar = function(_mouse_x, _mouse_y) {
            var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
            var _view_size   = _is_vertical ? __.height : __.width;

            if (__.content_size <= _view_size) return false;

            var _mx = _mouse_x - __.x;
            var _my = _mouse_y - __.y;

            if (_is_vertical) {
                var _sb_x = __.width - __.scrollbar_thickness;
                return (_mx >= _sb_x && _mx <= __.width && _my >= 0 && _my <= __.height);
            } else {
                var _sb_y = __.height - __.scrollbar_thickness;
                return (_mx >= 0 && _mx <= __.width && _my >= _sb_y && _my <= __.height);
            }
        }
        static __is_hover_thumb = function(_mouse_x, _mouse_y) {
            var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
            var _view_size   = _is_vertical ? __.height : __.width;

            if (__.content_size <= _view_size) return false;

            var _mx = _mouse_x - __.x;
            var _my = _mouse_y - __.y;

            var _thumb_size = __get_thumb_size();
            var _thumb_pos  = __.scroll / (__.content_size - _view_size) * (_view_size - _thumb_size);
            _thumb_pos      = clamp(_thumb_pos, __.scrollbar_padding, _view_size - _thumb_size - __.scrollbar_padding - 1);

            if (_is_vertical) {
                var _sb_x  = __.width - __.scrollbar_thickness + __.scrollbar_padding;
                var _sb_x2 = __.width - __.scrollbar_padding;
                if (_mx < _sb_x || _mx > _sb_x2) return false;
                return (_my >= _thumb_pos && _my <= _thumb_pos + _thumb_size);
            } else {
                var _sb_y  = __.height - __.scrollbar_thickness + __.scrollbar_padding;
                var _sb_y2 = __.height - __.scrollbar_padding;
                if (_my < _sb_y || _my > _sb_y2) return false;
                return (_mx >= _thumb_pos && _mx <= _thumb_pos + _thumb_size);
            }
        }
    }

    #endregion
    #region Helpers

    // Private
    with (__) {
        static __get_thumb_size = function() {
            var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
            var _view_size   = _is_vertical ? __.height : __.width;
            var _scroll_area = _view_size - __.scrollbar_padding * 2;
            var _view_ratio  = _view_size / __.content_size;

            return max(round(_scroll_area * _view_ratio), __.scrollbar_thumb_min);
        }
    }

    #endregion
    #region Cleanup

    // Public
    static cleanup = function() {
        surface_free(__.surface);
    }

    #endregion
}