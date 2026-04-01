// +-----------------------------------------------------------+
// |                                                           |
// |   ______   ______   ______   ______   __       __         |
// |  /\  ___\ /\  ___\ /\  == \ /\  __ \ /\ \     /\ \        |
// |  \ \___  \\ \ \____\ \  __< \ \ \/\ \\ \ \____\ \ \____   |
// |   \/\_____\\ \_____\\ \_\ \_\\ \_____\\ \_____\\ \_____/  |
// |    \/_____/ \/_____/ \/_/ /_/ \/_____/ \/_____/ \/_____/  |
// |                                                           |
// +-----------------------------------------------------------+
// class.ScrollContainer

enum ScrollAxis {
    Vertical,
    Horizontal
}
enum ScrollListPart {
    Thumb,
    Scrollbar
}
enum ScrollListSizeMode {
    ScrollbarIncluded, // List size is variable; list shrink by scrollbar thickness when bar appears
    ScrollbarExcluded, // List size is fixed; container grows by scrollbar thickness when bar appears
}

function ScrollContainer(_config = {}) : UIElement(_config) constructor {
	var _self = self;
	
	#region Config
	
	// Private
	with (__) {
		// Defaults
	    scroll_axis	 = _config[$ "scroll_axis" ] ?? ScrollAxis.Vertical;
	    size_mode	 = _config[$ "size_mode"   ] ?? ScrollListSizeMode.ScrollbarIncluded;
		scroll_lerp	 = _config[$ "scroll_lerp" ] ?? 0.1;
	    scroll_speed = _config[$ "scroll_speed"] ?? 20;
		scroll        = 0;
	    scroll_target = 0;
		
		// Build our scroll elements
		var _scroll_list_area = _self.__get_scroll_list_area();
		scroll_list = new ScrollList({
			x:			_scroll_list_area[$ "x"		],
			y:			_scroll_list_area[$ "y"		],
			width:		_scroll_list_area[$ "width" ],
			height:		_scroll_list_area[$ "height"],
			scroll_axis: scroll_axis,
			children:	_config[$ "children" ] ?? array_create(20), // TODO Placeholder
		});
		scroll_bar = new ScrollBar({
			// TODO Calculate size and pos
		});
	}
	
	#endregion
	#region Initialize
	
	on_initialize(function() {
        __.scroll = 0;
		__.scroll_target = 0;
		__.scroll_list.initialize();
		__.scroll_bar.initialize();
	});
	
	#endregion
	#region Update
	
	on_update(function() {
		__.scroll_list.update();
		__.scroll_bar.update();
	});
	
	#endregion
	#region Render
	
	// Events
	on_render(function() {
		__.scroll_list.render();
	});
	
	#endregion
	#region Helpers

    // Private
    with (__) {
		static __is_vertical = function() {
			return __.scroll_axis == ScrollAxis.Vertical;	
		}
		static __get_scroll_list_area = function() {
			var _rect = {};
			switch (__is_vertical()) {
				case true:
					show_debug_message("Vertical");
					_rect.x = __.x;
					_rect.y = __.y;
					_rect.width = __.width;
					_rect.height = __.height;
					break;
				case false:
					show_debug_message("Horizontal");
					break;
			}
			
			return _rect;
		}
        //static __needs_scrollbar = function(_view_w, _view_h) {
        //    var _is_vertical = (__.scroll_axis == ScrollAxis.Vertical);
        //    var _view_size   = _is_vertical ? _view_h : _view_w;
        //    var _count       = array_length(__.children);
        //    var _format      = __.ui_format;

        //    var _cursor = _format.first_item_offset();

        //    for (var _i = 0; _i < _count; _i++) {
        //        var _item = __.children[_i];
        //        _cursor  += _format.gap_before(_i);
        //        _cursor  += _is_vertical ? _item.get_height() : _item.get_width();

        //        // Early exit, scrollbar definitely needed
        //        if (_cursor + _format.get_content_inset() > _view_size) return true;
        //    }

        //    _cursor += _format.get_content_inset(); // Trailing inset
        //    return (_cursor > _view_size);
        //}
    }

    #endregion
	#region Cleanup
	
	on_cleanup(function() {
		__.scroll_list.cleanup();
		__.scroll_bar.cleanup();
	});
	
	#endregion
}