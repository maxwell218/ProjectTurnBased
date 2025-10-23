/// @description Initialize lifeform
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

// Stats class for the relevant lifeform
stats = undefined;

// Instance of the hex tile on which the lifeform is currently on
current_tile = noone;
last_tile = noone;

// A ds_map of all the tiles reachable with the available moves 
move_range_map = undefined;

#region Methods

init = function(_world_cell) {
	
	current_tile = _world_cell;
	last_tile = current_tile;
	update_move_range();
}

is_reachable_tile = function(_goal_tile) {
	
	if (ds_exists(move_range_map, ds_type_map)) {
		if (ds_map_exists(move_range_map, _goal_tile)) return true;
	}
	
	return false;
}

update_move_range = function() {
	
	if (ds_exists(move_range_map, ds_type_map)) {
		ds_map_destroy(move_range_map);
	}
	
	move_range_map = get_movement_range(current_tile, stats.get_stat(LifeformStat.MovePoints));
}

get_movement_range = function(_start_tile, _max_cost) {
	
	var _open = ds_queue_create();
	var _cost_map = ds_map_create();

	ds_queue_enqueue(_open, _start_tile);
	ds_map_add(_cost_map, _start_tile, 0);

	while (ds_queue_size(_open) > 0) {
	    var _current = ds_queue_dequeue(_open);
	    var _current_cost = _cost_map[? _current];
		
		show_debug_message(_current);

	    var _neighbors = global.world.get_hex_neighbors(_current);

	    for (var _i = 0; _i < array_length(_neighbors); _i++) {
	        var _n = _neighbors[_i];
	        if (!ds_map_exists(_cost_map, _n)) {
	            var _move_cost = global.world.get_tile_cost(_n);
	            var _new_cost = _current_cost + _move_cost;

	            if (_current_cost < _max_cost) {
	                ds_map_add(_cost_map, _n, _new_cost);
	                ds_queue_enqueue(_open, _n);
	            }
	        }
	    }
	}
	
	ds_queue_destroy(_open);
	return _cost_map;	
}



#endregion