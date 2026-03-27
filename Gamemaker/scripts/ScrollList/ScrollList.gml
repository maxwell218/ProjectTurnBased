
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
enum ScrollListSizeMode {
    ScrollbarIncluded, // List size is fixed; items shrink by scrollbar_thickness when bar appears
    ScrollbarExcluded, // Item area is fixed; list grows by scrollbar_thickness when bar appears
}

function ScrollList(_config) : UIParent(_config) constructor {
    var _self = self;

    #region Config

    // Public
    #region Getters

    static get_width = function() {
        var _w = __.width;

        if (__.scroll_axis == ScrollAxis.Vertical
        &&  __.size_mode   == ScrollListSizeMode.ScrollbarExcluded
        &&  __.has_scrollbar) {
            _w += __.scrollbar_thickness;
        }

        return _w;
    }
    static get_height = function() {
        var _h = __.height;

        if (__.scroll_axis == ScrollAxis.Horizontal
        &&  __.size_mode   == ScrollListSizeMode.ScrollbarExcluded
        &&  __.has_scrollbar) {
            _h += __.scrollbar_thickness;
        }

        return _h;
    }

    #endregion

    // Private
    with (__) {
        // Scroll axis
        scroll_axis = _config[$ "scroll_axis"] ?? ScrollAxis.Vertical;

        // Size mode
        size_mode = _config[$ "size_mode"] ?? ScrollListSizeMode.ScrollbarIncluded;

        // Scroll behaviour
        scroll        = 0;
        scroll_target = 0;
        scroll_lerp   = _config[$ "scroll_lerp" ] ?? 0.1;
        scroll_speed  = _config[$ "scroll_speed"] ?? 20;

        // Scrollbar appearance
        scrollbar_needed    = false;
        scrollbar_color     = _config[$ "scrollbar_color"    ] ?? COLORS.col_green_dark;
        scrollbar_thickness = _config[$ "scrollbar_thickness"] ?? 6;
        scrollbar_padding   = _config[$ "scrollbar_padding"  ] ?? 1;
        scrollbar_thumb_min = _config[$ "scrollbar_thumb_min"] ?? 20;
        scrollbar_selected  = false;

        // Background
        bg_color    = _config[$ "bg_color"   ] ?? c_dkgray;
        line_height = _config[$ "line_height"] ?? 8;

        // Content / surface
        content_size = 0;
        surface      = -1;

        // has_scrollbar is the single source of truth for whether the bar
        // is visible — drives rendering and hover detection in both modes
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

        var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);

        for (var _i = 0; _i < _count; _i++) {
            var _item_main  = 73;
            var _item_cross = __.ui_format.available_cross(_is_vertical ? __.width : __.height);

            var _config = {
                x:      0,
                y:      0,
                width:  _is_vertical ? _item_cross : _item_main,
                height: _is_vertical ? _item_main  : _item_cross,
                item:   "Item " + string(_i),
            };

            array_push(__.children, new ScrollListItem(_config));
        }
    }

    #endregion
    #region Resize

    // Public
    static measure_size = function(_available_width, _available_height) {
        var _view_w = (_available_width  > 0) ? _available_width  : __.width;
        var _view_h = (_available_height > 0) ? _available_height : __.height;

        var _need_scrollbar = __needs_scrollbar(_view_w, _view_h);

        var _measured_w = _view_w;
        var _measured_h = _view_h;

        if (__.size_mode == ScrollListSizeMode.ScrollbarExcluded && _need_scrollbar) {
            if (__.scroll_axis == ScrollAxis.Vertical) {
                _measured_w += __.scrollbar_thickness;
            } else {
                _measured_h += __.scrollbar_thickness;
            }
        }

        return { width: _measured_w, height: _measured_h };
    }
    static resize = function(_config) {
        __.x = _config[$ "x"] ?? __.x;
        __.y = _config[$ "y"] ?? __.y;

        var _outer_w = _config[$ "width" ] ?? get_width();
        var _outer_h = _config[$ "height"] ?? get_height();

        var _content_w = _outer_w;
        var _content_h = _outer_h;

        if (__.size_mode == ScrollListSizeMode.ScrollbarExcluded) {
            if (__.scroll_axis == ScrollAxis.Vertical) {
                if (__needs_scrollbar(_outer_w, _outer_h)) {
                    _content_w -= __.scrollbar_thickness;
                }
            } else {
                if (__needs_scrollbar(_outer_w, _outer_h)) {
                    _content_h -= __.scrollbar_thickness;
                }
            }
        }

        __.width  = _content_w;
        __.height = _content_h;

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
            var _local_pos = _is_vertical
                ? (obj_cursor.gui_y - __.y)
                : (obj_cursor.gui_x - __.x);

            var _thumb_size = __get_thumb_size();
            var _track_size = _view_size - _thumb_size;

            _local_pos = clamp(_local_pos - (_thumb_size * 0.5), 0, _track_size);

            __.scroll_target = _local_pos / _track_size * (_content_size - _view_size);
        }

        // Clamp + smooth
        __.scroll_target = clamp(__.scroll_target, 0, max(0, _content_size - _view_size));
        __.scroll        = lerp(__.scroll, __.scroll_target, __.scroll_lerp);

        // --- Visible-child culling along the main axis ---
        var _top_view    = __.scroll;
        var _bottom_view = __.scroll + _view_size;
        var _count       = array_length(__.children);

        var _i = 0;
        while (_i < _count) {
            var _item     = __.children[_i];
            var _item_end = _is_vertical
                ? (_item.get_y() + _item.get_height())
                : (_item.get_x() + _item.get_width());
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
        var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
        var _count       = array_length(__.children);
        var _layout      = __.ui_format;

        // Cross-axis usable size (inset subtracted symmetrically on both sides)
        var _cross_size = _layout.available_cross(_is_vertical ? __.width : __.height);

        // --- Pass 1: place all items using layout helper ---
        // cursor begins at content_inset; gap_before() adds item_spacing only
        // between items, never before the first or after the last.
        var _cursor = _layout.first_item_offset();

        for (var _i = 0; _i < _count; _i++) {
            var _item = __.children[_i];
            _cursor  += _layout.gap_before(_i);   // 0 for item 0; item_spacing for _i > 0

            if (_is_vertical) {
                _item.set_x(_layout.content_inset);
                _item.set_y(_cursor);
                _item.set_width(_cross_size);
                _cursor += _item.get_height();
            } else {
                _item.set_x(_cursor);
                _item.set_y(_layout.content_inset);
                _item.set_height(_cross_size);
                _cursor += _item.get_width();
            }
        }

        // Trailing inset closes the content region
        _cursor += _layout.content_inset;

		// Compare content size to view size, determine if scrollbar is needed
        var _view_size      = _is_vertical ? __.height : __.width;
        __.content_size     = max(_cursor, _view_size);
        __.scrollbar_needed = (__.content_size > _view_size);
        __.has_scrollbar    = __.scrollbar_needed;

        // --- Pass 2: shrink cross-axis in ScrollbarIncluded mode ---
        // ScrollbarExcluded: list grows outward — item width is unaffected.
        // ScrollbarIncluded: scrollbar overlaps the list rect — items must
        //                    yield cross-axis space to keep content readable.
        if (__.size_mode == ScrollListSizeMode.ScrollbarIncluded && __.has_scrollbar) {
            var _shrunk_cross = _cross_size - __.scrollbar_thickness;
            for (var _i = 0; _i < _count; _i++) {
                var _item = __.children[_i];
                if (_is_vertical) {
                    _item.set_width(_shrunk_cross);
                } else {
                    _item.set_height(_shrunk_cross);
                }
            }
        }
    }

    #endregion
    #region Render

    // Public
    static render = function() {
		#region Surface / Background
		
        if (!surface_exists(__.surface)) {
            __.surface = surface_create(get_width(), get_height());
        }

        surface_set_target(__.surface);
        draw_clear_alpha(c_black, 0);

        draw_set_color(__.bg_color);
        draw_rectangle(0, 0, __.width, __.height, false);
		
		#endregion
		#region Children
		
        var _context = {
            scroll_axis: __.scroll_axis,
            scroll_x:    (__.scroll_axis == ScrollAxis.Horizontal) ? __.scroll : 0,
            scroll_y:    (__.scroll_axis == ScrollAxis.Vertical)   ? __.scroll : 0,
			border_mode: __.ui_format.border_mode,
        };
        var _hovered_child = undefined;
        for (var _i = __.child_draw_start; _i < __.child_draw_start + __.child_draw_amount; _i++) {
            var _child = __.children[_i];
            _child.render(_context);
            if (_hovered_child == undefined && _child.get_is_hovered()) {
                _hovered_child = _child;
            }
        }
		
		// Render hover
        if (_context.border_mode != UIBorderMode.None && _hovered_child != undefined && UI_MANAGER.get_active_element() == undefined) {
            _hovered_child.render_hover(_context);
        }
		
		#endregion
		#region Scrollbar
		
        if (__.has_scrollbar) {
            __render_scrollbar();
            __render_thumb();
        }
		
		#endregion
		
		// TODO Implement better border system
		draw_set_color(c_white);
		
		
		// Reset and draw
        surface_reset_target();
        draw_surface(__.surface, __.x, __.y);
		
		__render_borders();
    }
    static render_gui = function() {
        if (global.debug) {
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_text(__.x, __.y + get_height(),                  "scroll = "       + string(__.scroll));
            draw_text(__.x, __.y + get_height() + __.line_height, "content_size = " + string(__.content_size));
        }
    }

    // Private
    with (__) {
        static __get_scrollbar_x = function() {
            if (__.scroll_axis != ScrollAxis.Vertical) return 0;

            switch (__.size_mode) {
                case ScrollListSizeMode.ScrollbarIncluded: return __.width - __.scrollbar_thickness;
                case ScrollListSizeMode.ScrollbarExcluded: return __.width;
            }

            return __.width - __.scrollbar_thickness;
        }
        static __get_scrollbar_y = function() {
            if (__.scroll_axis != ScrollAxis.Horizontal) return 0;

            switch (__.size_mode) {
                case ScrollListSizeMode.ScrollbarIncluded: return __.height - __.scrollbar_thickness;
                case ScrollListSizeMode.ScrollbarExcluded: return __.height;
            }

            return __.height - __.scrollbar_thickness;
        }
        static __render_scrollbar = function() {
            var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
            draw_set_color(c_olive);

            if (_is_vertical) {
                var _sx = __get_scrollbar_x();
                draw_rectangle(_sx, 0, _sx + __.scrollbar_thickness, __.height, false);
            } else {
                var _sy = __get_scrollbar_y();
                draw_rectangle(0, _sy, __.width, _sy + __.scrollbar_thickness, false);
            }
        }
        static __render_thumb = function() {
            var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
            var _view_size   = _is_vertical ? __.height : __.width;
            var _thumb_size  = __get_thumb_size();
            var _thumb_pos   = __.scroll / (__.content_size - _view_size) * (_view_size - _thumb_size);
            var _sb_padding  = __.scrollbar_padding;

            _thumb_pos = clamp(_thumb_pos, _sb_padding, _view_size - _thumb_size - _sb_padding - 1);
			
			var _condition = 
			(UI_MANAGER.get_active_element() == self || UI_MANAGER.get_active_element() == undefined) 
			&& (__.scrollbar_selected || __.pseudo_elements[ScrollListPart.Thumb].is_hovered);
			
            var _thumb_color = (_condition) ? c_white : __.scrollbar_color;
            draw_set_color(_thumb_color);

            if (_is_vertical) {
                var _sx = __get_scrollbar_x();
                draw_rectangle(
                    _sx + _sb_padding,
                    _thumb_pos,
                    _sx + __.scrollbar_thickness - _sb_padding - 1,
                    _thumb_pos + _thumb_size,
                    false
                );
            } else {
                var _sy = __get_scrollbar_y();
                draw_rectangle(
                    _thumb_pos,
                    _sy + _sb_padding,
                    _thumb_pos + _thumb_size,
                    _sy + __.scrollbar_thickness - _sb_padding - 1,
                    false
                );
            }
        }
		static __render_borders = function() {
			draw_sprite_stretched(spr_ui_borders, 0, __.x, __.y, get_width(), get_height());
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
            if (!__.has_scrollbar) return false;

            var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
            var _mx = _mouse_x - __.x;
            var _my = _mouse_y - __.y;

            if (_is_vertical) {
                var _sx = __get_scrollbar_x();
                return (_mx >= _sx && _mx <= _sx + __.scrollbar_thickness
                    &&  _my >= 0   && _my <= __.height);
            } else {
                var _sy = __get_scrollbar_y();
                return (_mx >= 0   && _mx <= __.width
                    &&  _my >= _sy && _my <= _sy + __.scrollbar_thickness);
            }
        }
        static __is_hover_thumb = function(_mouse_x, _mouse_y) {
            if (!__.has_scrollbar) return false;

            var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
            var _view_size   = _is_vertical ? __.height : __.width;
            var _mx = _mouse_x - __.x;
            var _my = _mouse_y - __.y;

            var _thumb_size = __get_thumb_size();
            var _thumb_pos  = __.scroll / (__.content_size - _view_size) * (_view_size - _thumb_size);
            _thumb_pos      = clamp(_thumb_pos, __.scrollbar_padding, _view_size - _thumb_size - __.scrollbar_padding - 1);

            if (_is_vertical) {
                var _sx  = __get_scrollbar_x();
                var _sx1 = _sx + __.scrollbar_padding;
                var _sx2 = _sx + __.scrollbar_thickness - __.scrollbar_padding - 1;
                return (_mx >= _sx1       && _mx <= _sx2
                    &&  _my >= _thumb_pos && _my <= _thumb_pos + _thumb_size);
            } else {
                var _sy  = __get_scrollbar_y();
                var _sy1 = _sy + __.scrollbar_padding;
                var _sy2 = _sy + __.scrollbar_thickness - __.scrollbar_padding - 1;
                return (_mx >= _thumb_pos && _mx <= _thumb_pos + _thumb_size
                    &&  _my >= _sy1       && _my <= _sy2);
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
        static __needs_scrollbar = function(_view_w, _view_h) {
            var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
            var _view_size   = _is_vertical ? _view_h : _view_w;
            var _count       = array_length(__.children);
            var _layout      = __.ui_format;

            var _cursor = _layout.first_item_offset();

            for (var _i = 0; _i < _count; _i++) {
                var _item = __.children[_i];
                _cursor  += _layout.gap_before(_i);
                _cursor  += _is_vertical ? _item.get_height() : _item.get_width();

                // Early exit, scrollbar definitely needed
                if (_cursor + _layout.content_inset > _view_size) return true;
            }

            _cursor += _layout.content_inset; // Trailing inset
            return (_cursor > _view_size);
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