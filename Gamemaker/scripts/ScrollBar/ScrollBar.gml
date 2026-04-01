// +-----------------------------------------------------------+
// |                                                           |
// |   ______   ______   ______   ______   __       __         |
// |  /\  ___\ /\  ___\ /\  == \ /\  __ \ /\ \     /\ \        |
// |  \ \___  \\ \ \____\ \  __< \ \ \/\ \\ \ \____\ \ \____   |
// |   \/\_____\\ \_____\\ \_\ \_\\ \_____\\ \_____\\ \_____/  |
// |    \/_____/ \/_____/ \/_/ /_/ \/_____/ \/_____/ \/_____/  |
// |                                                           |
// +-----------------------------------------------------------+
// class.ScrollBar

function ScrollBar(_config = {}) : UIElement(_config) constructor {
	var _self = self;
	
	#region Config
	
	// Private
	with (__) {
	    is_needed   = false;
		is_selected = false;
	    bg_color    = _config[$ "bg_color" ] ?? c_dkgray;
	    thickness	= _config[$ "thickness"] ?? 7;
	    thumb_size_min	= _config[$ "thumb_size_min"] ?? 20;
	}
	
	#endregion
	#region Initialize
	
	on_initialize(function() {
		__.is_selected = false;
	});
	
	#endregion
	#region Hover
	
	
	
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
            var _format      = __.ui_format;

            var _cursor = _format.first_item_offset();

            for (var _i = 0; _i < _count; _i++) {
                var _item = __.children[_i];
                _cursor  += _format.gap_before(_i);
                _cursor  += _is_vertical ? _item.get_height() : _item.get_width();

                // Early exit, scrollbar definitely needed
                if (_cursor + _format.get_content_inset() > _view_size) return true;
            }

            _cursor += _format.get_content_inset(); // Trailing inset
            return (_cursor > _view_size);
        }
    }

    #endregion
}