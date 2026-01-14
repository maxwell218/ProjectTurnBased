function ScrollListView(_x_pos, _y_pos, _width, _height, _data) constructor {
	
	#region Methods
	
	init = function() {
		
		// Update scroll position
		scrollbar_selected = false;
		scroll_target = 0;
		scroll = 0;
		
		var _count = array_length(children);
		
		// Debug
		array_delete(children, 0, _count);
		
		for (var _i = 0; _i < _count; _i++) {
			
			var _item_width = width - margin * 2;
			var _item_height = (_i % 2 == 0)? 60 : 30;
			
			var _item = new ScrollListItem(_item_width - 1, _item_height - 1, "Item " + string(_i));

			array_push(children, _item);
		}
		
		rebuild_content();
	}
	
	step = function() {
		
		// On scroll bar click, allow scrolling
		if (scrollbar_selected) {
			var _local_y = mouse_y - y; // Convert from global → local space

			var _thumb_height = get_thumb_height();
			var _track_height = height - _thumb_height;

			// Clamp local click inside track
			_local_y = clamp(_local_y - (_thumb_height * 0.5), 0, _track_height);

			// Convert local thumb position into scroll value
			scroll_target = _local_y / _track_height * (content_height - height);
		}
		
		// Handle mouse wheel scroll
		else if (hovered) {
			
			// Get mouse wheel input
		    var _mw = mouse_wheel_up() - mouse_wheel_down();
		    if (_mw != 0) {
		        scroll_target -= _mw * scroll_speed;
			}
		}
		
		// Clamp target
		scroll_target = clamp(scroll_target, 0, max(0, content_height - height));
		
		// Smooth lerp
	    scroll = lerp(scroll, scroll_target, scroll_lerp);
		
		// Get children in scroll view
		var _top_view = scroll;
		var _bottom_view = scroll + height;
		var _count = array_length(children);
		
		// Find first item within visible region
		var _i = 0;
	    while (_i < _count) {
			
	        var _item = children[_i];
	        var _item_bottom = _item.y + _item.height;

	        if (_item_bottom >= _top_view)
	            break;

	        _i++;
	    }
		
		child_draw_start = _i;
		
		// Get items within visible region
	    while (_i < _count) {
	        var _item = children[_i];
			
			_item.hovered = false;
			
			// Check if item in view is hovered
			if (hovered) {
			    _item.is_hover(x, y, scroll);
			}

	        // Stop when item is below view
	        if (_item.y > _bottom_view)
	            break;
				
	        _i++;
	    }
		
		child_draw_amount = _i - child_draw_start;
    }
	
	on_click = function(_states) {
		
		show_debug_message("test");
			
		// Handle scrollbar selection / deselection
		if (_states[$ Input.Select].pressed && (is_hover_thumb() || is_hover_scrollbar())) {
			scrollbar_selected = true;
		} 	
		
		if (scrollbar_selected && _states[$ Input.Select].released) {
			scrollbar_selected = false;
		}
	}
	
	cleanup = function() {
		// TODO
		// Context removal
		
		// Surface free
		surface_free(surface);
	}
	
	update_children = function(_new_children) {
		
		children = _new_children;
		init();
	}
	
	rebuild_content = function() {

        // Calculate required height
        var _yy = margin;
        var _count = array_length(children);

        for (var _i = 0; _i < _count; _i++) {
			
			var _item = children[_i];
			_item.x = margin;
			_item.y = _yy;
			
			_yy += _item.height + margin + 1;
        }

        content_height = max(_yy, height);
		
		// Check if we have a scrollbar
		if (content_height > height) {
			
			// Set new item width
			for (var _i = 0; _i < _count; _i++) {
				
				var _item = children[_i];
				_item.width -= scrollbar_width;
			}
		}
    }
	
	draw = function() {
		
		// Ensure the surface exists
		if (!surface_exists(surface)) {
		    surface = surface_create(width, height);
		}

		// Render visible region every frame
		surface_set_target(surface);
		draw_clear_alpha(c_black, 0);
		
		// Draw background
        draw_set_color(bg_color);
        draw_rectangle(0, 0, width, height, false);

		// Draw visible items
		for (var _i = child_draw_start; _i < child_draw_start + child_draw_amount; _i++) {
			children[_i].draw(scroll);
		}

		// Draw scrollbar
		if (content_height > height) {
			
			// Compute scrollbar thumb size
		    var _thumb_height = get_thumb_height();
		    var _thumb_pos = scroll / (content_height - height) * (height - _thumb_height);
			
			_thumb_pos = clamp(_thumb_pos, scrollbar_margin, height - _thumb_height - scrollbar_margin - 1);

		    var _sx = width - scrollbar_width;
		    var _sy = _thumb_pos;
			
			// Draw scrollbar background
			draw_set_color(c_olive);
			draw_rectangle(_sx, 0, width, height, false);
			
			if (scrollbar_selected || is_hover_thumb()) {
				draw_set_color(c_white);
			} else {
				draw_set_color(scrollbar_color);
			}
			
		    draw_rectangle(_sx + scrollbar_margin, _sy, width - scrollbar_margin - 1, _sy + _thumb_height, false);
		}
		
		draw_set_color(c_white);
		surface_reset_target();

		// Draw the clipped region
		draw_surface(surface, x, y);
    }
	
	draw_gui = function() {
		
		if (global.debug) {
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			
			draw_text(x, y + height, "scroll = " + string(scroll));
			draw_text(x, y + height + line_height, "content_height = " + string(content_height));
		}
	}
	
	get_thumb_height = function() {
		
		var _view_ratio = height / content_height;
		var _scroll_area = height - scrollbar_margin * 2;
		return max(round(_scroll_area * _view_ratio), scrollbar_thumb_min);
	}
	
	is_hover = function() {
		
		hovered = false;
		
		if (point_in_rectangle(mouse_x, mouse_y, x, y, x + width, y + height)) {
			hovered = true;
		}
		
		return hovered;
	}
	
	is_hover_scrollbar = function() {

	    if (content_height <= height)
	        return false; // Scrollbar not visible

	    var _mx = mouse_x - x;
	    var _my = mouse_y - y;

	    var _sb_x  = width - scrollbar_width;
	    var _sb_x2 = _sb_x + scrollbar_width;

	    return (_mx >= _sb_x && _mx <= _sb_x2 && _my >= 0 && _my <= height);
	}

	is_hover_thumb = function() {

	    if (content_height <= height)
	        return false; // Scrollbar not visible

	    var _mx = mouse_x - x;
	    var _my = mouse_y - y;

	    // Scrollbar X bounds
	    var _sb_x  = width - scrollbar_width + scrollbar_margin;
	    var _sb_x2 = width - scrollbar_margin;
		
	    if (_mx < _sb_x || _mx > _sb_x2)
	        return false;

	    // Thumb vertical bounds
		var _thumb_height = get_thumb_height();
		var _thumb_pos = scroll / (content_height - height) * (height - _thumb_height);
			
		_thumb_pos = clamp(_thumb_pos, scrollbar_margin, height - _thumb_height - scrollbar_margin - 1);

	    return (_my >= _thumb_pos && _my <= _thumb_pos + _thumb_height);
	}
	
	#endregion
	
	#region Variables
	
	x = _x_pos;
	y = _y_pos;
	width = _width;
	height = _height;

	children = _data;
	child_draw_start = 0;
	child_draw_amount = 0;
	
	margin = 5;
	line_height = 8;
	
	bg_color = c_dkgray;
	
	// Scroll variables
	scroll = 0;				// Actual scroll position
    scroll_target  = 0;		// Target scroll position (smooth)
    scroll_lerp = 0.1;		// Smooth factor
	scroll_speed = 20;
	
	// Scrollbar variables
	scrollbar_color = c_ltgray;
	scrollbar_width = 12;
	scrollbar_height = undefined;
	scrollbar_margin = 2;
	scrollbar_thumb_min = 20;
	scrollbar_selected = false;
	
	surface = -1;
	content_height = 0;
	
	hovered = true;
	hovered_item = undefined;
	
	#endregion
	
}