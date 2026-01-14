/// @description Initialize all lifeform variables

enum TurnOrder {
	Player,
	Ai,
	Last
}

enum LifeformType {
	Human,
	Animal,
	Monster,
	Last
}

enum LifeformStat {
	
	// Health
	CurrentHealth,
	MaxHealth,
	
	// Morale
	CurrentMorale,
	MaxMorale,
	
	// Tiredness
	CurrentFatigue,
	MaxFatigue,
	
	// Needs
	CurrentHunger,
	MaxHunger,
	CurrentThirst,
	MaxThirst,
	
	// Strength, used for carry capacity, base damage calculations
	Strength,
	
	// Movement
	MovePoints,
	
	Last	
}

#region Methods

create_lifeform = function(_lifeform_type) {
	
	var _stats = undefined;
	
	switch (_lifeform_type) {
		case LifeformType.Human:
		default:
			_stats = new HumanStats();
			break;
	}
	
	return new LifeformMember(_lifeform_type, _stats);
}

create_lifeform_group = function(_members, _faction, _id = undefined) {
	
	// TODO Assign leader (maybe _members[0] or based on stats?)
	var _lifeform_group = new LifeformGroup(_members, undefined, _faction, _id);
	
	// Add the new group to the map
	ds_map_add(lifeform_groups, _lifeform_group.group_id, _lifeform_group);
	
	return _lifeform_group;
}

create_player_lifeform = function() {
	
	// TODO Give starting traits and stats
	return create_lifeform(LifeformType.Human);
}

get_player_lifeform_group = function() {
	
	return lifeform_groups[? PLAYER_GROUP_ID];
}

is_movement_active = function() {
	
	return time_source_get_state(lifeform_group_movement_timer) == time_source_state_active;
}

move_group_along_path = function(_lifeform_group) {
	
	// Stop the time source if we've reached the end of the path / reached an encounter
	if (array_length(lifeform_group_path) <= 0) {
		
		time_source_stop(lifeform_group_movement_timer);
		time_source_reset(lifeform_group_movement_timer);
		
		event_manager_publish(Event.LifeformGroupDestinationReached, _lifeform_group);
	}
	
	// If we still have a tile to move towards
    if (array_length(lifeform_group_path) > 0) {
		
        var _next_tile = lifeform_group_path[0];
		
		// Move lifeform group on world map
		global.world.move_lifeform_group(_lifeform_group, _next_tile);
		
		// Move lifeform group (members) to the center of the next tile
		_lifeform_group.set_new_tile(_next_tile);

        /// Remove the tile we just stepped onto
        array_delete(lifeform_group_path, 0, 1);
		
		// Configure and start time source for next steps
		time_source_reconfigure(lifeform_group_movement_timer, lifeform_group_movement_duration, time_source_units_seconds, move_group_along_path, [_lifeform_group], -1);
		time_source_start(lifeform_group_movement_timer);
    }
	
	// TODO Check if we triggered an encounter
}

#endregion

#region Variables

// Keeps track of whose turn it is
current_turn = TurnOrder.Player;

// Keeps track of all active lifeforms in the current world
lifeform_groups = ds_map_create();

// Used to move lifeform groups one tile at a time
lifeform_group_movement_duration = 0.4 // Duration for each step in seconds
lifeform_group_movement_timer = time_source_create(time_source_game, lifeform_group_movement_duration, time_source_units_seconds, move_group_along_path, [], -1);

// Keeps track of the path a lifeform group should follow
lifeform_group_path = [];

#endregion

#region Events

event_manager_subscribe(Event.WorldCreated, function() {
	
	// Create player lifeform
	var _player_group = [];
	
	// TODO Only one lifeform at start
	_player_group[0] = create_lifeform(LifeformType.Human);
	_player_group[1] = create_lifeform(LifeformType.Human);
	_player_group[2] = create_lifeform(LifeformType.Human);
	_player_group[3] = create_lifeform(LifeformType.Human);
	
	// Create player lifeform group
	var _player_lifeform_group = create_lifeform_group(_player_group, undefined, PLAYER_GROUP_ID);
	
	event_manager_publish(Event.LifeformGroupCreated, _player_lifeform_group);
	
	// TODO Generate other lifeforms
});

event_manager_subscribe(Event.TurnEnd, function() {
	
	current_turn = (current_turn == TurnOrder.Player)? TurnOrder.Ai : TurnOrder.Player;
});

event_manager_subscribe(Event.WorldCellSelected, function(_cell_data) {

	// Check if we are already moving a group
	if (is_movement_active()) {
		return;	
	}
	
	// Get player lifeform group
	var _player_group = get_player_lifeform_group();
	
	// Check if tile is within movement range of group
	if (!_player_group.is_reachable_tile(_cell_data)) {
		show_debug_message("Out of range!");
		exit;
	}

	lifeform_group_path = global.world.get_path(_player_group.current_tile, _cell_data, _player_group.get_min_movement_range());
	move_group_along_path(_player_group);
});

event_manager_subscribe(Event.LifeformGroupDestinationReached, function(_lifeform_group) {
	
	// Update move range maps
	_lifeform_group.on_movement_end();
});

#endregion