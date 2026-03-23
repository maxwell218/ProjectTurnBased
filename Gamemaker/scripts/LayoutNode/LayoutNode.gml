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
	var _self = self;

    #region Config
	
	// Public
	#region Getters

    static get_element         = function() { return __.element;         }
    static get_width           = function() { return __.width;           }
    static get_height          = function() { return __.height;          }
    static get_margin          = function() { return __.margin;          }
    static get_is_dirty        = function() { return __.is_dirty;        }
    static get_resolved_x      = function() { return __.resolved_x;      }
    static get_resolved_y      = function() { return __.resolved_y;      }
    static get_resolved_width  = function() { return __.resolved_width;  }
    static get_resolved_height = function() { return __.resolved_height; }

    #endregion

	// Private
    __ = {};
    with (__) {
        element				= _config[$ "element"];
        width				= _config[$ "width"  ] ?? new LayoutSizeFill();
        height				= _config[$ "height" ] ?? new LayoutSizeFill();
        margin				= new LayoutMargin(_config[$ "margin"] ?? 0);
        parent_layout		= _config[$ "parent_layout"];
        is_dirty			= true;

        // Cached resolved values — undefined until first resolve
        resolved_x      = undefined;
        resolved_y      = undefined;
        resolved_width  = undefined;
        resolved_height = undefined;
    }

    #endregion
    #region Dirty

    // Public
    static mark_dirty = function() {
        __.is_dirty = true;
        __.parent_layout.mark_dirty(self);
    }
    static clear_dirty = function() {
        __.is_dirty = false;
    }
    static set_resolved = function(_x, _y, _width, _height) {
        __.resolved_x      = _x;
        __.resolved_y      = _y;
        __.resolved_width  = _width;
        __.resolved_height = _height;
    }

    #endregion
}