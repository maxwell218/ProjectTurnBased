// +---------------------------------------------------------+
// |                                                         |
// |   __       ______   __  __   ______   __  __   ______   |
// |  /\ \     /\  __ \ /\ \_\ \ /\  __ \ /\ \/\ \ /\__  _\  |
// |  \ \ \____\ \  __ \\ \____ \\ \ \/\ \\ \ \_\ \\/_/\ \/  |
// |   \ \_____\\ \_\ \_\\/\_____\\ \_____\\ \_____\  \ \_\  |
// |    \/_____/ \/_/\/_/ \/_____/ \/_____/ \/_____/   \/_/  |
// |                                                         |
// +---------------------------------------------------------+
// class.LayoutFixed

function LayoutFixed(_config) constructor {
	var _self = self;
	
	#region Config
	
	// Public
	#region Getters
	
	static get_type   = function() { return __.type;   }
    static get_pixels = function() { return __.pixels; }
	
	#endregion
	
	// Private
    __ = {};
    with (__) {
        type   = LayoutSizeType.Fixed;
        pixels = _config[$ "pixels"] ?? undefined;
    }
		
	#endregion
}