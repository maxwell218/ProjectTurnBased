// +---------------------------------------------------------+
// |                                                         |
// |   __       ______   __  __   ______   __  __   ______   |
// |  /\ \     /\  __ \ /\ \_\ \ /\  __ \ /\ \/\ \ /\__  _\  |
// |  \ \ \____\ \  __ \\ \____ \\ \ \/\ \\ \ \_\ \\/_/\ \/  |
// |   \ \_____\\ \_\ \_\\/\_____\\ \_____\\ \_____\  \ \_\  |
// |    \/_____/ \/_/\/_/ \/_____/ \/_____/ \/_____/   \/_/  |
// |                                                         |
// +---------------------------------------------------------+
// class.LayoutSizeFixed

function LayoutSizeFixed(_config) constructor {
	var _self = self;

    #region Config
	
	// Public
	#region Getters
	
    static get_px = function() { return __.px; }

    #endregion
	
	// Private
	__ = {};
	with (__) {
        px = _config[$ "px"] ?? 0;
    }

    #endregion
    #region Resolve

    // Public
    static resolve = function(_fill_unit = 0, _content_size = 0) {
        return __.px;
    }

    #endregion
}