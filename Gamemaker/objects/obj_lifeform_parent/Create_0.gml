#region Methods

init = function(_current_tile) {
	
	update_move_range(_current_tile);
}
	
// Edge cases:
// If we have a severe cut with max severity, we need the health system to transform the injury from cut to deep wound
// If we have severe bruising with max severity, we need to create a new fracture injury to the same body part, while keeping all other active injuries
add_injury = function(_body_part, _injury) {
    
}

add_modifier = function(_source, _target, _value) {
    
    var _mod = { source: _source, target: _target, value: _value };
    array_push(modifiers, _mod);
}

remove_modifier = function(_source) {
    
    for (var _i = array_length(modifiers) - 1; _i >= 0; _i--) {
        if (modifiers[_i].source == _source) {
            array_delete(modifiers, _i, 1);
        }
    }
}

get_final_stat = function(_name) {
    
    var _value = stats.base[_name];
    if (is_undefined(_value)) return 0;
    for (var _i = 0; _i < array_length(modifiers); _i++) {
        var _mod = modifiers[_i];
        if (_mod.target == _name) _value += _mod.value;
    }
    return _value;
}

is_reachable_tile = function(_goal_tile) {
	
	if (ds_exists(move_range_map, ds_type_map)) {
		if (ds_map_exists(move_range_map, _goal_tile)) return true;
	}
	
	return false;
}

update_move_range = function(_current_tile) {
	
	if (ds_exists(move_range_map, ds_type_map)) {
		ds_map_destroy(move_range_map);
	}
	
	move_range_map = get_movement_range(_current_tile, get_final_stat(LifeformStat.MovePoints));
}

get_movement_range = function(_start_tile, _max_cost) {
		
	var _world_ref = global.world;
	
	var _open = ds_queue_create();
	var _cost_map = ds_map_create();

	ds_queue_enqueue(_open, _start_tile);
	ds_map_add(_cost_map, _start_tile, 0);

	while (ds_queue_size(_open) > 0) {
		var _current = ds_queue_dequeue(_open);
		var _current_cost = _cost_map[? _current];

		var _neighbors = _world_ref.get_hex_neighbors(_current);

		for (var _i = 0; _i < array_length(_neighbors); _i++) {
		    var _n = _neighbors[_i];
		    if (!ds_map_exists(_cost_map, _n)) {
		        var _move_cost = _world_ref.get_tile_cost(_n);
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
	
destroy = function() {
	
	if (ds_exists(move_range_map, ds_type_map)) ds_map_destroy(move_range_map);	
}
	
#endregion

// Array of structs {source, target, value}
modifiers = [];

// Define default stats
self[$ "stats"] ??= new HumanStats();
	
// A ds_map of all the tiles reachable with the available moves 
move_range_map = undefined;