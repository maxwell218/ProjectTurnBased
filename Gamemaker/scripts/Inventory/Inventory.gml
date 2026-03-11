// +----------------------------------------------------------------------------------+
// |                                                                                  |
// |   __   __   __   __   __ ______   __   __   ______  ______   ______   __  __     |
// |  /\ \ /\ "-.\ \ /\ \ / //\  ___\ /\ "-.\ \ /\__  _\/\  __ \ /\  == \ /\ \_\ \    |
// |  \ \ \\ \ \-.  \\ \ \'/ \ \  __\ \ \ \-.  \\/_/\ \/\ \ \/\ \\ \  __< \ \____ \   |
// |   \ \_\\ \_\\"\_\\ \__|  \ \_____\\ \_\\"\_\  \ \_\ \ \_____\\ \_\ \_\\/\_____\  |
// |    \/_/ \/_/ \/_/ \/_/    \/_____/ \/_/ \/_/   \/_/  \/_____/ \/_/ /_/ \/_____/  |
// |                                                                                  |
// +----------------------------------------------------------------------------------+
// class.Inventory

function Inventory(_config = {}) constructor {
	
    var _self = self;
	
	__ = {};
    
    #region Config
	
	// Private
    with(__) {
		
		x = _config[$ "x"] ?? 0; // TODO Transfer to gui inventory
		y = _config[$ "y"] ?? 0;
		cols = _config[$ "cols"] ?? 1; // TODO Defined by lifeform
		rows = _config[$ "rows"] ?? 1;
		
        cell_sprite = _config[$ "cell_sprite"] ?? undefined;
		containers 	= _config[$ "containers" ] ?? [];
		// TODO Equipment and slots
		
    }
    
    #endregion
    #region Render
    
	// Public
    static render = function() {
		draw_set_valign(fa_top);
		draw_set_halign(fa_left);
		draw_text(__.x, __.y, "Inventory");
		draw_text(__.x, __.y + 12, string(__.cols) + ", " + string(__.rows));
	}

    #endregion
	
}