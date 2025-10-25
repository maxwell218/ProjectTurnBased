/// @description Define turn order

enum TurnOrder {
	Player,
	Ai,
	Last,
}

enum LifeformType {
	Human,
	Animal,
	Monster,
	Last
}

enum LifeformStat {
	MovePoints,
	Last	
}

// Keeps track of whose turn it is
current_turn = TurnOrder.Player;

// Keeps track of all active lifeforms in the current world
lifeform_groups = ds_map_create();

#region Methods

create_lifeform = function(_lifeform_type, _world_cell) {
	
	var _inst = noone;
	
	switch(_lifeform_type) {
		default:
			var _x = _world_cell[CellData.X] + HEX_WIDTH div 2;
			var _y = _world_cell[CellData.Y] + HEX_HEIGHT div 2;
			
			_inst = instance_create_layer(_x, _y, "Lifeforms", obj_human);
			
			// Assign base stats
			_inst.stats = new HumanStats();
			break;
	}
	
	// Link the instance to its tile struct
    _inst.init();
	
	array_push(_world_cell[CellData.Lifeforms], _inst);
	
	return _inst;
}

create_lifeform_group = function(_id = undefined) {
	
	var _lifeform_group = undefined;
	return new LifeformGroup(undefined, undefined, undefined);
}

move_lifeform = function(_lifeform, _next_tile) {
	
	// We need to remove the lifeform reference within the current tile
	
	//var _lifeform_index = 
	
	//array_delete(_lifeform.current_tile[CellData.Lifeforms], _lifeform_index, 1);
	
	//var _old_tile = get_world_data(_lifeform.current_tile[CellData.Row], _lifeform.current_tile[CellData.Col]);

	//show_debug_message(_old_tile);
	//show_debug_message(_lifeform.current_tile);
	//show_debug_message(overworld.world_data[0][0]);
}

move_along_path = function(_lifeform, _path) {
	
    if (array_length(_path) > 0) {
		
        var _next_tile = _path[0];
        
        // Move the lifeform to the center of the next tile
        _lifeform.x = _next_tile[CellData.X] + HEX_WIDTH div 2;
        _lifeform.y = _next_tile[CellData.Y] + HEX_HEIGHT div 2;
		
		// Move lifeform on world map
		global.world.move_lifeform(_lifeform, _next_tile);

        ///// Remove the tile we just stepped onto
        //array_delete(_path, 0, 1);

        //// Trigger the controller alarm for the next step
        //obj_lifeform_controller.alarm[0] = STEP_DELAY; // STEP_DELAY = frames to wait
    } 
}

#endregion

#region Events

event_manager_subscribe(Event.WorldCreated, function() {
	
	// Create player group
	var _player_group = create_lifeform_group(PLAYER_GROUP_ID);
	
	event_manager_publish(Event.LifeformGroupCreated, _player_group);
	
	// TODO Generate other lifeforms
	
});

event_manager_subscribe(Event.TurnEnd, function() {
	
	current_turn = (current_turn == TurnOrder.Player)? TurnOrder.Ai : TurnOrder.Player;
});

event_manager_subscribe(Event.CellSelected, function(_cell_data) {
	
	// Check if tile is within movement range
	
	//if (!player.is_reachable_tile(hovered_hex.cell_data)) {
	//	show_debug_message("Out of range!");
	//	exit;
	//}

	//var _path = get_path(player.current_tile, hovered_hex.cell_data, player.stats.get_stat(LifeformStat.MovePoints));
		
	//global.lifeform_controller.move_along_path(player, _path);
});

#endregion