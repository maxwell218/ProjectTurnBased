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

function ScrollList(_config = {}) : UIParent(_config) constructor {
    var _self = self;

    #region Config

    // Public
    #region Getters

	static get_content_size = function() { return __.content_size; }

    #endregion

    // Private
    with (__) {
	    scroll_axis	 = _config[$ "scroll_axis" ] ?? ScrollAxis.Vertical;
		scroll		 = _config[$ "scroll"	   ] ?? 0;
	    content_size = 0;
	    surface      = -1;

	    // Visible-child culling
	    child_render_start  = 0;
	    child_render_amount = 0;
	}

    #endregion
    #region Initialize
	
	// Events
	on_initialize(function() {
		// TODO: Replace placeholder item construction with injected content
        var _count = array_length(__.children);
        array_delete(__.children, 0, _count);

        var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);

        for (var _i = 0; _i < _count; _i++) {
            var _item_main  = 73;
            // var _item_cross = __.ui_format.available_cross(_is_vertical ? __.width : __.height);
			var _item_cross = _is_vertical? __.width : __.height;

            var _config = {
                x:      0,
                y:      0,
                width:  _is_vertical ? _item_cross : _item_main,
                height: _is_vertical ? _item_main  : _item_cross,
                item:   "Item " + string(_i),
            };

            array_push(__.children, new ScrollListItem(_config));
        }
	});

    #endregion
    #region Update

    // Public
    static _update = function() {
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
        __.child_render_start = _i;

        while (_i < _count) {
            var _item       = __.children[_i];
            var _item_start = _is_vertical ? _item.get_y() : _item.get_x();
            if (_item_start > _bottom_view) break;
            _i++;
        }
        __.child_render_amount = _i - __.child_render_start;
    }

    #endregion
    #region Rebuild

    // Public
    static rebuild_content = function() {
        var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
        var _count       = array_length(__.children);
        var _format      = __.ui_format;

        // Cross-axis usable size (inset subtracted symmetrically on both sides)
        var _cross_size = _format.available_cross(_is_vertical ? __.width : __.height);

        // --- Pass 1: place all items using layout helper ---
        // cursor begins at content_inset; gap_before() adds item_spacing only
        // between items, never before the first or after the last.
        var _cursor = _format.first_item_offset();

        for (var _i = 0; _i < _count; _i++) {
            var _item = __.children[_i];
            _cursor  += _format.gap_before(_i);   // 0 for item 0; item_spacing for _i > 0

            if (_is_vertical) {
                _item.set_x(_format.get_content_inset());
                _item.set_y(_cursor);
                _item.set_width(_cross_size);
                _cursor += _item.get_height();
            } else {
                _item.set_x(_cursor);
                _item.set_y(_format.get_content_inset());
                _item.set_height(_cross_size);
                _cursor += _item.get_width();
            }
        }

        // Trailing inset closes the content region
        _cursor += _format.get_content_inset();

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
    static _render = function() {
		#region Surface / Background
		
		__render_border();
		
        if (!surface_exists(__.surface)) {
            __.surface = surface_create(__.width, __.height);
        }

        surface_set_target(__.surface);
        draw_clear_alpha(c_black, 0);

        draw_set_color(__.bg_color);
        draw_sprite_stretched(spr_ui_bg, 0, 0, 0, __.width, __.height);
		
		#endregion
		#region Children
		
        var _context = {
            scroll_axis: __.scroll_axis,
            scroll_x:    (__.scroll_axis == ScrollAxis.Horizontal) ? __.scroll : 0,
            scroll_y:    (__.scroll_axis == ScrollAxis.Vertical)   ? __.scroll : 0,
			border_mode: __.ui_format.get_border_mode(),
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
        //if (_context.border_mode != UIBorderMode.None && _hovered_child != undefined && UI_MANAGER.get_active_element() == undefined) {
        //    _hovered_child.render_hover(_context);
        //}
		
		#endregion
		#region Reset / Draw
		
		draw_set_color(c_white);
		
		// Reset and draw
        surface_reset_target();
        draw_surface(__.surface, __.x, __.y);
		
		#endregion
		#region Scrollbar
		
		if (__.has_scrollbar) {
            __render_scrollbar();
			__render_thumb();
        }
		
		#endregion
    }
    static _render_gui = function() {
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
                case ScrollListSizeMode.ScrollbarIncluded: return __.x + __.width - __.scrollbar_thickness;
                case ScrollListSizeMode.ScrollbarExcluded: return __.x + __.width;
            }
        }
        static __get_scrollbar_y = function() {
            if (__.scroll_axis != ScrollAxis.Horizontal) return 0;

            switch (__.size_mode) {
                case ScrollListSizeMode.ScrollbarIncluded: return __.y + __.height - __.scrollbar_thickness;
                case ScrollListSizeMode.ScrollbarExcluded: return __.y + __.height;
            }
        }
        static __render_scrollbar = function() {
            var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical); 
			var _border_sprite = __.ui_format.get_border_sprite();
			draw_set_color(c_olive);
            if (_is_vertical) {
                var _sx = __get_scrollbar_x();
				draw_sprite_stretched(_border_sprite, 0, _sx, __.y, __.scrollbar_thickness, __.height);
            } else {
                var _sy = __get_scrollbar_y();
				draw_sprite_stretched(_border_sprite, 0, __.x, _sy, __.width, __.scrollbar_thickness);
            }
			draw_set_color(c_white);
        }
        static __render_thumb = function() {
		    var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);

		    var _view_size  = _is_vertical ? __.height : __.width;
		    var _track_start = _is_vertical ? __.y : __.x;
		    var _track_end   = _track_start + _view_size;

		    var _thumb_size = __get_thumb_size();
		    var _sb_padding = __.scrollbar_padding;

		    var _scroll_range = max(__.content_size - _view_size, 1);
		    var _track_range  = max(_view_size - _thumb_size - (_sb_padding * 2), 0);

		    var _thumb_pos = _track_start + _sb_padding + (__.scroll / _scroll_range) * _track_range;
		    _thumb_pos = clamp(_thumb_pos, _track_start + _sb_padding, _track_end - _thumb_size - _sb_padding);

		    var _thumb_color = (__.scrollbar_selected || __.pseudo_elements[ScrollListPart.Thumb].is_hovered)
		        ? c_white
		        : __.scrollbar_color;

		    draw_set_color(_thumb_color);

		    if (_is_vertical) {
		        var _sx = __get_scrollbar_x();
		        draw_rectangle(
		            _sx + _sb_padding,
		            _thumb_pos,
		            _sx + __.scrollbar_thickness - _sb_padding - 1,
		            _thumb_pos + _thumb_size - 1,
		            false
		        );
		    } else {
		        var _sy = __get_scrollbar_y();
		        draw_rectangle(
		            _thumb_pos,
		            _sy + _sb_padding,
		            _thumb_pos + _thumb_size - 1,
		            _sy + __.scrollbar_thickness - _sb_padding - 1,
		            false
		        );
		    }

		    draw_set_color(c_white);
		}
    }
	
	// Events
	on_render(function() {
		
	});

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
                    &&  _my >= __.y   && _my <= __.y + __.height);
            } else {
                var _sy = __get_scrollbar_y();
                return (_mx >= __.x && _mx <= __.x + __.width
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
    #region Cleanup

    // Events
	on_cleanup(function() {
		surface_free(__.surface);
	});

    #endregion
}