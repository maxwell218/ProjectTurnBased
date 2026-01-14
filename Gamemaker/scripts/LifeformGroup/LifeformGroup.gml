#macro PLAYER_GROUP_ID 0

#macro MAX_GROUP_SIZE         4
#macro MAX_GROUP_WIDTH        (HALF_HEX_WIDTH - 14)
#macro MAX_GROUP_HALF_WIDTH   (MAX_GROUP_WIDTH div 2)
#macro GROUP_ROW_HEIGHT       8
#macro MAX_PER_ROW            2

function LifeformGroup(_members, _leader, _faction, _id = undefined) constructor {
	
	#region Methods
	
	init = function(_world_cell) {
		
		current_tile = _world_cell;
		
		var _member_count = array_length(members);
		for (var _i = 0; _i < _member_count; _i++) {
			
			var _x = _world_cell[CellData.X] + HEX_WIDTH div 2;
			var _y = _world_cell[CellData.Y] + HEX_HEIGHT div 2;
			
			var _instance = instance_create_layer(_x, _y, "Lifeforms", obj_human);
			members[_i].init(_instance, _world_cell);
		}
		
		array_push(_world_cell[CellData.LifeformGroups], self);
	}
	
	is_reachable_tile = function(_goal_tile) {
		
		var _member_count = array_length(members);
		if (_member_count == 0) return undefined;
		
		for (var _m = 0; _m < _member_count; _m++) {
			
			var _member = members[_m];
			
			if (!_member.is_reachable_tile(_goal_tile)) {
				return false;	
			}
		}
		
		return true;
	}
	
	get_min_movement_range = function() {
		
		var _min_move_member = get_min_movement_member();
		return _min_move_member.stats.get_final_stat(LifeformStat.MovePoints);
	}
	
	get_min_movement_member = function() {
		
		var _member_count = array_length(members);
		if (_member_count == 0) return undefined;
		
		var _min_move = infinity;
		var _min_move_member = undefined;
		
		for (var _m = 0; _m < _member_count; _m++) {
			
			var _member = members[_m];
			var _move = _member.stats.get_final_stat(LifeformStat.MovePoints);
			
			if (_move < _min_move) {
				_min_move = _move;
				_min_move_member = _member;
			}
		}
		
		return _min_move_member;
	}
	
	set_new_tile = function(_new_tile) {
		
		current_tile = _new_tile;
	}
	
	on_movement_end = function() {
		
		// Update move range maps
		var _member_count = array_length(members);
		for (var _i = 0; _i < _member_count; _i++) {
			members[_i].update_move_range(current_tile);
		}
	}

    // Destroy method to recycle ID
    destroy = function() {
		
        array_push(free_ids, group_id); // Recycle ID
        members = [];
        leader  = undefined;
        faction = undefined;
    }
	
	draw = function(_x_offset = 0, _y_offset = 0) {
	
		if (current_tile != undefined) {
		
			var _x_middle = current_tile[CellData.X] + HEX_WIDTH div 2 + _x_offset;
			var _y_middle = current_tile[CellData.Y] + HEX_HEIGHT div 2 + _y_offset;
		
			var _count = array_length(members);
		
			// Determine layout
			var _rows = 1;
			var _members_in_row = [];
		
			if (_count <= MAX_PER_ROW) {
				_rows = 1;
				_members_in_row[0] = _count;
			}
			else if (_count == 3) {
				_rows = 2;
				_members_in_row[0] = 2;
				_members_in_row[1] = 1;
			}
			else {
				_rows = 2;
				_members_in_row[0] = 2;
				_members_in_row[1] = 2;
			}
		
			// Y positions per row
			var _row_y = [];
			if (_rows == 1) {
				_row_y[0] = _y_middle;
			} else {
				_row_y[0] = _y_middle - GROUP_ROW_HEIGHT;
				_row_y[1] = _y_middle;
			}
		
			// Draw each member
			var _member_index = 0;
			for (var _r = 0; _r < _rows; _r++) {
			
				var _count_in_row = _members_in_row[_r];
				var _x_positions = [];
			
				switch (_count_in_row) {
					case 1:
						_x_positions[0] = _x_middle;
						break;
					case 2:
						_x_positions[0] = _x_middle - MAX_GROUP_HALF_WIDTH / 2;
						_x_positions[1] = _x_middle + MAX_GROUP_HALF_WIDTH / 2;
						break;
				}
			
				for (var _c = 0; _c < _count_in_row; _c++) {
					var _member = members[_member_index];
					var _draw_x = _x_positions[_c];
					var _draw_y = _row_y[_r];
				
					_member.draw(_draw_x, _draw_y);
				
					_member_index++;
				}
			}
		}
	}
	
	draw_move_range = function() {
		
		var _min_move_map = get_min_movement_member().move_range_map;
		
		if (_min_move_map != undefined) {
			
			var _keys = ds_map_keys_to_array(_min_move_map);
			for (var _i = 0; _i < array_length(_keys); _i++) {
			    var _tile = _keys[_i];

			    // Draw translucent overlay on each reachable tile
			    var _cost = _min_move_map[? _tile];
		
				if _cost == 0 continue;
		
				draw_sprite_ext(spr_hex_tile_hover, 0, _tile[CellData.X], _tile[CellData.Y], 1, 1, 0, c_aqua, 0.5);
				
				draw_set_color(c_black);
			    draw_text(_tile[CellData.X] + HEX_WIDTH div 2 + 1, _tile[CellData.Y] + HEX_HEIGHT - 8, string(_cost));
			    draw_text(_tile[CellData.X] + HEX_WIDTH div 2, _tile[CellData.Y] + HEX_HEIGHT - 8 + 1, string(_cost));
			    draw_text(_tile[CellData.X] + HEX_WIDTH div 2 - 1, _tile[CellData.Y] + HEX_HEIGHT - 8, string(_cost));
			    draw_text(_tile[CellData.X] + HEX_WIDTH div 2, _tile[CellData.Y] + HEX_HEIGHT - 8 - 1, string(_cost));
				draw_set_color(c_white);
				draw_text(_tile[CellData.X] + HEX_WIDTH div 2, _tile[CellData.Y] + HEX_HEIGHT - 8, string(_cost));
			}
		}
	}
	
	#endregion
	
	#region Variables
	
	// Static variables (shared between all LifeformGroup instances)
    static next_id = 1;
    static free_ids = []; // Reusable IDs

    // Assign ID
	if (_id != undefined) {
		group_id = _id;
	} else {
	    if (array_length(free_ids) > 0) {
	        group_id = array_pop(free_ids); // Take first free ID
	    } else {
	        group_id = next_id;
	        next_id += 1;
	    }
	}

    // Assign other properties
    members = _members;
    leader  = _leader;
    faction = _faction;
	
	// Reference of the cell on which the lifeform is currently on
	current_tile = undefined;
	
	#endregion
}