// +---------------------------------------------------------+
// |                                                         |
// |   __       ______   __  __   ______   __  __   ______   |
// |  /\ \     /\  __ \ /\ \_\ \ /\  __ \ /\ \/\ \ /\__  _\  |
// |  \ \ \____\ \  __ \\ \____ \\ \ \/\ \\ \ \_\ \\/_/\ \/  |
// |   \ \_____\\ \_\ \_\\/\_____\\ \_____\\ \_____\  \ \_\  |
// |    \/_____/ \/_/\/_/ \/_____/ \/_____/ \/_____/   \/_/  |
// |                                                         |
// +---------------------------------------------------------+
// class.LayoutContent

function LayoutContent() constructor {
	var _self = self;
	
	#region Config
	
	#region Getters
	
	static get_type = function() { return __.type; }
	
	#endregion
	
	// Private
    __ = {};
    with (__) {
        type = LayoutSizeType.Content;
    }
	
	#endregion
}