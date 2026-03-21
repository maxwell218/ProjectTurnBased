// +---------------------------------------------------------+
// |                                                         |
// |   __       ______   __  __   ______   __  __   ______   |
// |  /\ \     /\  __ \ /\ \_\ \ /\  __ \ /\ \/\ \ /\__  _\  |
// |  \ \ \____\ \  __ \\ \____ \\ \ \/\ \\ \ \_\ \\/_/\ \/  |
// |   \ \_____\\ \_\ \_\\/\_____\\ \_____\\ \_____\  \ \_\  |
// |    \/_____/ \/_/\/_/ \/_____/ \/_____/ \/_____/   \/_/  |
// |                                                         |
// +---------------------------------------------------------+
// class.LayoutMargin

function LayoutMargin(_config) constructor {

    #region Config
	
	// Public
	#region Getters

    static get_top    = function() { return __.top;    }
    static get_right  = function() { return __.right;  }
    static get_bottom = function() { return __.bottom; }
    static get_left   = function() { return __.left;   }

    static get_horizontal = function() { return __.left + __.right;  }
    static get_vertical   = function() { return __.top  + __.bottom; }

    #endregion
	
	// Private
	__ = {};
    with (__) {
        if (is_real(_config)) {
            top    = _config;
            right  = _config;
            bottom = _config;
            left   = _config;
        } else if (_config[$ "h"] != undefined || _config[$ "v"] != undefined) {
            var _h = _config[$ "h"] ?? 0;
            var _v = _config[$ "v"] ?? 0;
            top    = _v;
            right  = _h;
            bottom = _v;
            left   = _h;
        } else {
            top    = _config[$ "top"   ] ?? 0;
            right  = _config[$ "right" ] ?? 0;
            bottom = _config[$ "bottom"] ?? 0;
            left   = _config[$ "left"  ] ?? 0;
        }
    }

    #endregion
}