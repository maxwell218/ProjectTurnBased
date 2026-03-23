// +-------------------+
// |                   |
// |   __  __   __     |
// |  /\ \/\ \ /\ \    |
// |  \ \ \_\ \\ \ \   |
// |   \ \_____\\ \_\  |
// |    \/_____/ \/_/  |
// |                   |
// +-------------------+
// class.UIPlaceholder

function UIPlaceholder(_config) : UIChild(_config) constructor {
	
	static render = function() {
		draw_sprite_stretched(spr_ui_bg, 0, __.x, __.y, __.width, __.height);	
	}
}