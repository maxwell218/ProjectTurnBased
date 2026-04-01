// +---------------------------------------------------------+
// |                                                         |
// |   __       ______   __  __   ______   __  __   ______   |
// |  /\ \     /\  __ \ /\ \_\ \ /\  __ \ /\ \/\ \ /\__  _\  |
// |  \ \ \____\ \  __ \\ \____ \\ \ \/\ \\ \ \_\ \\/_/\ \/  |
// |   \ \_____\\ \_\ \_\\/\_____\\ \_____\\ \_____\  \ \_\  |
// |    \/_____/ \/_/\/_/ \/_____/ \/_____/ \/_____/   \/_/  |
// |                                                         |
// +---------------------------------------------------------+
// class.LayoutNode

function LayoutNode(_config) constructor {
	// TODO Nomenclature
	
	// Public
	#region Getters
	
	static get_element         = function() { return __.element;         }
	static get_element_format  = function() {
		if (variable_struct_exists(__.element, "get_ui_format")) {
			return __.element.get_ui_format();
		}
		
		return undefined;
	}
    static get_size_x          = function() { return __.size_x;          }
    static get_size_y          = function() { return __.size_y;          }
    static get_margin          = function() { return __.margin;          }
    static get_resolved_x      = function() { return __.resolved_x;      }
    static get_resolved_y      = function() { return __.resolved_y;      }
    static get_resolved_width  = function() { return __.resolved_width;  }
    static get_resolved_height = function() { return __.resolved_height; }
	static get_visual_leading = function(_is_h) {
		if (variable_struct_exists(__.element, "get_visual_leading")) {
	        return __.element.get_visual_leading(_is_h);
	    }
	    return 0;
	}
	static get_visual_trailing = function(_is_h) {
	    if (variable_struct_exists(__.element, "get_visual_trailing")) {
	        return __.element.get_visual_trailing(_is_h);
	    }
	    return 0;
	}
	
	#endregion
	
	// Private
    __ = {};
    with (__) {
        element = _config[$ "element"];
        size_x  = _config[$ "size_x" ] ?? new LayoutFill();
        size_y  = _config[$ "size_y" ] ?? new LayoutFill();

        var _m  = _config[$ "margin"] ?? 0;
        margin  = is_real(_m) ? new LayoutMargin(_m) : _m;

        // Optional measurement callback — function(_element) -> { width, height }
        // Must be provided when size_x or size_y is LayoutContent.
        measure = _config[$ "measure"] ?? undefined;

        // Written by LayoutContainer during solve()
        resolved_x      = 0;
        resolved_y      = 0;
        resolved_width  = 0;
        resolved_height = 0;
    }

    // Invoked by LayoutContainer — calls the measure callback if present
    static get_content_size = function(_available_w, _available_h) {
	    if (__.measure == undefined) {
	        show_error("LayoutNode: LayoutContent used but no measure callback provided.", true);
	    }
	    return __.measure(__.element, _available_w, _available_h);
	}

    // Pushes the solved rect back into the wrapped element
    static apply_resolved = function(_x, _y, _w, _h) {
        __.resolved_x      = _x;
        __.resolved_y      = _y;
        __.resolved_width  = _w;
        __.resolved_height = _h;
        __.element.resize({ x: _x, y: _y, width: _w, height: _h });
    }
}