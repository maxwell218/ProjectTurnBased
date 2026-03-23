// +---------------------------------------------------+
// |                                                   |
// |   ______   ______   ______   __   __   ______     |
// |  /\  ___\ /\  ___\ /\  ___\ /\ "-.\ \ /\  ___\    |
// |  \ \___  \\ \ \____\ \  __\ \ \ \-.  \\ \  __\    |
// |   \/\_____\\ \_____\\ \_____\\ \_\\"\_\\ \_____\  |
// |    \/_____/ \/_____/ \/_____/ \/_/ \/_/ \/_____/  |
// |                                                   |
// +---------------------------------------------------+
// class.Scene

function Scene(_config) constructor {
	var _self = self;
	
	#region Config
	
	// Public
	#region Getters

    // Public
    static get_layout   = function() { return __.layout;   }
    static get_elements = function() { return __.elements; }

    #endregion

    // Private
	__ = {};
    with (__) {
        layout   = undefined; // set in build()
        elements = {};        // named element instances, populated in build()
    }

    #endregion
    #region Build

    // Public
    static build = function() {
        // Implemented by each concrete scene
    }

    #endregion
    #region Activate / Deactivate

    // Public
    static activate = function() {
	    if (__.layout == undefined) {
	        show_error("Scene has not been built. Call build() before activate().", true);
	    }
	    __.layout.resolve();
	    event_manager_publish(Event.ActivateScene, self);
		event_manager_subscribe(Event.ViewResized, function(_config) {
			__.layout.resize({
				width:  _config[$ "width" ] ?? undefined,
	            height: _config[$ "height"] ?? undefined,
	        });
		});
	}
	static deactivate = function() {
	    if (__.layout == undefined) {
	        show_error("Scene has not been built. Call build() before deactivate().", true);
	    }
	    event_manager_unsubscribe(Event.ViewResized);
	}

    #endregion
	#region Step

    // Public
    static step = function() {
        var _names = variable_struct_get_names(__.elements);
        var _count = array_length(_names);
        for (var _i = 0; _i < _count; _i++) {
            var _element = __.elements[$ _names[_i]];
            if (variable_struct_exists(_element, "step")) {
                _element.step();
            }
        }
    }

    #endregion
	#region Hover

    // Public
    static collect_hover = function(_mouse_x, _mouse_y, _hovered_stack, _context = {}) {
		var _names = variable_struct_get_names(__.elements);
        var _count = array_length(_names);
        for (var _i = 0; _i < _count; _i++) {
            var _element = __.elements[$ _names[_i]];
            if (variable_struct_exists(_element, "collect_hover")) {
                _element.collect_hover(_mouse_x, _mouse_y, _hovered_stack, _context);;
            }
        }
    }

    #endregion
    #region Render

    // Public
    static render = function() {
        var _names = variable_struct_get_names(__.elements);
        var _count = array_length(_names);
        for (var _i = 0; _i < _count; _i++) {
            var _element = __.elements[$ _names[_i]];
            if (variable_struct_exists(_element, "render")) {
                _element.render();
            }
        }
    }

    #endregion
}