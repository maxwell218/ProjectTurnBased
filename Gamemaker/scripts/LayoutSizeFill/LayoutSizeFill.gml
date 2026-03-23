// +---------------------------------------------------------+
// |                                                         |
// |   __       ______   __  __   ______   __  __   ______   |
// |  /\ \     /\  __ \ /\ \_\ \ /\  __ \ /\ \/\ \ /\__  _\  |
// |  \ \ \____\ \  __ \\ \____ \\ \ \/\ \\ \ \_\ \\/_/\ \/  |
// |   \ \_____\\ \_\ \_\\/\_____\\ \_____\\ \_____\  \ \_\  |
// |    \/_____/ \/_/\/_/ \/_____/ \/_____/ \/_____/   \/_/  |
// |                                                         |
// +---------------------------------------------------------+
// class.LayoutSizeFill

function LayoutSizeFill(_config = {}) constructor {
	var _self = self;
	
    #region Config
	
	// Public
	#region Getters

    static get_share = function() { return __.share; }

    #endregion
	
	// Private
	__ = {};
    with (__) {
        share = _config[$ "share"] ?? 1;
    }

    #endregion
    #region Resolve

    // Public
    static resolve = function(_fill_unit = 0, _content_size = 0) {
        return round(__.share * _fill_unit);
    }

    #endregion
}