// +-----------------------------------------------------------+
// |                                                           |
// |   ______   ______   ______   ______   __       __         |
// |  /\  ___\ /\  ___\ /\  == \ /\  __ \ /\ \     /\ \        |
// |  \ \___  \\ \ \____\ \  __< \ \ \/\ \\ \ \____\ \ \____   |
// |   \/\_____\\ \_____\\ \_\ \_\\ \_____\\ \_____\\ \_____/  |
// |    \/_____/ \/_____/ \/_/ /_/ \/_____/ \/_____/ \/_____/  |
// |                                                           |
// +-----------------------------------------------------------+
// class.LayoutNode

function LayoutNode(_config, _parent_layout) constructor {

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
        element        = _config[$ "element"];
        width          = _config[$ "width"  ] ?? new LayoutSizeFill();
        height         = _config[$ "height" ] ?? new LayoutSizeFill();
        margin         = new LayoutMargin(_config[$ "margin"] ?? 0);
        parent_layout  = _parent_layout;
        is_dirty       = true; // dirty by default so first resolve always commits

        // Cached resolved values — undefined until first resolve
        resolved_x      = undefined;
        resolved_y      = undefined;
        resolved_width  = undefined;
        resolved_height = undefined;
    }

    // Inject dirty callback onto element without coupling element to layout
    var _node = self;
    element.on_dirty = function() {
        _node.mark_dirty();
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
    #region Hover

    // Public
    static collect_hover = function(_mouse_x, _mouse_y, _hovered_stack, _context = {}) {
        return __.element.collect_hover(_mouse_x, _mouse_y, _hovered_stack, _context);
    }

    #endregion
}