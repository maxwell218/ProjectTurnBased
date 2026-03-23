// +---------------------------------------------------------+
// |                                                         |
// |   __       ______   __  __   ______   __  __   ______   |
// |  /\ \     /\  __ \ /\ \_\ \ /\  __ \ /\ \/\ \ /\__  _\  |
// |  \ \ \____\ \  __ \\ \____ \\ \ \/\ \\ \ \_\ \\/_/\ \/  |
// |   \ \_____\\ \_\ \_\\/\_____\\ \_____\\ \_____\  \ \_\  |
// |    \/_____/ \/_/\/_/ \/_____/ \/_____/ \/_____/   \/_/  |
// |                                                         |
// +---------------------------------------------------------+
// class.LayoutFill

function LayoutFill(_config = {}) constructor {
	var _self = self;
	
	#region Config
	
	// Public
	#region Getters
	
	static get_type   = function() { return __.type;   }
    static get_weight = function() { return __.weight; }
	
	#endregion
	
	// Private
    __ = {};
    with (__) {
        type   = LayoutSizeType.Fill;
        weight = _config[$ "weight"] ?? 1;
    }
	
	#endregion
}