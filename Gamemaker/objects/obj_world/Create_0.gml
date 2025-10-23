/// @description Create all world components
#macro WORLD_HEIGHT 100
#macro WORLD_WIDTH 100

#macro HEX_HEIGHT sprite_get_height(spr_hex_tile)
#macro HEX_WIDTH sprite_get_width(spr_hex_tile)

#macro BUFFER_ROWS 2
#macro BUFFER_COLS 2

#macro COL_SPACING HEX_WIDTH * 3/4
#macro HALF_HEX_HEIGHT HEX_HEIGHT div 2

// Define terrain types
enum TerrainType {
	Plain,
	Mountain,
	Forest,
	Lake,
	Road,
	Town,
	City,
	Farmland,
	Junkyard,
	Lab,
	Bunker,
	Last
}

enum CubeCoordinate {
	CubeX,
	CubeY,
	CubeZ,
	Last
}

// Create overworld
overworld = new Overworld();

// Cube neighbors lookup array
cube_neighbors = [
    [+1, -1, 0], [+1, 0, -1], [0, +1, -1],
    [-1, +1, 0], [-1, 0, +1], [0, -1, +1]
];

// Contains the hovered hexagon object
hovered_hex = noone;

// Pooled hexes variables
pool = [];
pool_rows = 0;
pool_cols = 0;
anchor_row = 0;
anchor_col = 0;

#region Methods

create_lifeform = function(_lifeform_type, _world_cell) {
	
	var _inst = noone;
	
	switch(_lifeform_type) {
		default:
			var _x = _world_cell.cell_data[CellData.X] + HEX_WIDTH div 2;
			var _y = _world_cell.cell_data[CellData.Y] + HEX_HEIGHT div 2;
			
			_inst = instance_create_layer(_x, _y, "Lifeforms", obj_human);
			
			// Assign base stats
			_inst.stats = new HumanStats();
			break;
	}
	
	// Link the instance to its tile struct
    _inst.init(_world_cell.cell_data);
	
	array_push(_world_cell.cell_data[CellData.Lifeforms], _inst);
	
	return _inst;
}

/// @description Returns all neighbor structs from cell data
get_hex_neighbors = function(_cell_data) {
	var _cube_x = _cell_data[CellData.CubeX];
	var _cube_y = _cell_data[CellData.CubeY];
	
	var _neighbors = [];
	
	for (var _i = 0; _i < array_length(cube_neighbors); _i++) {
		
		var _new_x = _cube_x + cube_neighbors[_i][CubeCoordinate.CubeX];
		var _new_y = _cube_y + cube_neighbors[_i][CubeCoordinate.CubeY];
		
		var _coords = cube_to_offset(_new_x, _new_y);
		
		if (is_valid_coord(_coords[0], _coords[1])) {
			array_push(_neighbors, overworld.world_data[_coords[0]][_coords[1]].cell_data);
		}
	}
	
	return _neighbors;
}

/// @description Convert cube to coordinates 
cube_to_offset = function(_cube_x, _cube_y) {

	var _row = _cube_y + (_cube_x - (_cube_x & 1)) / 2;
	var _col = _cube_x;
	
	return [_row, _col];
}

/// @description Checks if a coord is valid within the world
is_valid_coord = function(_row, _col) {
	
	var _row_valid = _row >= 0 && _row < WORLD_HEIGHT;
	var _col_valid = _col >= 0 && _col < WORLD_WIDTH;
	
	return _row_valid && _col_valid;
}

hex_grid_to_pixel = function(_row, _col) {
	
    var _x = _col * COL_SPACING;
    var _y = _row * HEX_HEIGHT + ((_col mod 2) * HALF_HEX_HEIGHT);
    return [_x, _y];
}

pixel_to_hex_grid = function(_px, _py) {
	
    var _col = floor(_px / (COL_SPACING));
    var _y_offset = (_col mod 2) * (HEX_HEIGHT / 2);
    var _row = floor((_py - _y_offset) / HEX_HEIGHT);

    _col = clamp(_col, 0, WORLD_WIDTH - 1);
    _row = clamp(_row, 0, WORLD_HEIGHT - 1);

    return [_row, _col];
}

get_world_data = function(_row, _col) {
	
    if (!is_valid_coord(_row, _col)) return undefined;
    return overworld.world_data[_row][_col];
}

get_tile_cost = function(_hex) {
	
	return _hex[CellData.Cost];
}

get_hex_distance = function(_hex_a, _hex_b) {

    var _dx = abs(_hex_a[CellData.CubeX] - _hex_b[CellData.CubeX]);
    var _dy = abs(_hex_a[CellData.CubeY] - _hex_b[CellData.CubeY]);
    var _dz = abs(_hex_a[CellData.CubeZ] - _hex_b[CellData.CubeZ]);

    return max(_dx, _dy, _dz);
}

init_pool_for_camera = function() {
	
    var _cam = view_camera[0];
    var _vx  = camera_get_view_x(_cam);
    var _vy  = camera_get_view_y(_cam);
    var _vw  = camera_get_view_width(_cam);
    var _vh  = camera_get_view_height(_cam);

    // How many tiles are visible in camera (+1 for partial / stagger)
	var _visible_rows = ceil(_vh / HEX_HEIGHT) + 1 + BUFFER_ROWS;
	var _visible_cols = ceil(_vw / (COL_SPACING)) + 1 + BUFFER_COLS;
	
	pool_rows = _visible_rows;
	pool_cols = _visible_cols;

    // Compute top-left anchor tile (first fully visible tile)
    var _grid = pixel_to_hex_grid(_vx, _vy);
    anchor_row = _grid[0];
    anchor_col = _grid[1];
	
	// Clamp anchors
	anchor_row = clamp(anchor_row, 0, WORLD_HEIGHT - 1);
	anchor_col = clamp(anchor_col, 0, WORLD_WIDTH - 1);

    // Create 2D pool array: rows first
    pool = array_create(pool_rows);
    for (var _i = 0; _i < pool_rows; _i++) {
		pool[_i] = array_create(pool_cols);
	}

    // Spawn pooled instances
    for (var _i = 0; _i < pool_rows; _i++) {
        for (var _j = 0; _j < pool_cols; _j++) {
            var _world_row = anchor_row + _i;
            var _world_col = anchor_col + _j;

            var _xy = hex_grid_to_pixel(_world_row, _world_col);
            var _inst = instance_create_layer(_xy[0], _xy[1], "Tiles", obj_hex_tile);

            _inst.cell_data = get_world_data(_world_row, _world_col).cell_data;

            pool[_i][_j] = _inst;
        }
    }
}

reposition_pool = function() {
	
    var _cam_x = camera_get_view_x(view_camera[0]);
    var _cam_y = camera_get_view_y(view_camera[0]);

    var _new_anchor = pixel_to_hex_grid(_cam_x, _cam_y);
    var _new_anchor_row = clamp(_new_anchor[0] - 1, 0, WORLD_HEIGHT - pool_rows);
    var _new_anchor_col = clamp(_new_anchor[1] - 1, 0, WORLD_WIDTH - pool_cols);

    var _delta_row = _new_anchor_row - anchor_row;
    var _delta_col = _new_anchor_col - anchor_col;
    if (_delta_row == 0 && _delta_col == 0) return;

    // --- Vertical scroll ---
    if (_delta_row != 0) {
        if (_delta_row > 0) { // down
            for (var _i = 0; _i < _delta_row; _i++) {
                var _recycle = pool[0];
                for (var _r = 0; _r < pool_rows - 1; _r++) pool[_r] = pool[_r + 1];
                pool[pool_rows - 1] = _recycle;
                var _world_row = _new_anchor_row + pool_rows - 1 - _i;
                for (var _c = 0; _c < pool_cols; _c++) {
                    var _inst = _recycle[_c];
                    var _world_col = _new_anchor_col + _c;
                    var _xy = hex_grid_to_pixel(_world_row, _world_col);
                    _inst.x = _xy[0]; _inst.y = _xy[1];
                    _inst.cell_data = get_world_data(_world_row, _world_col).cell_data;
                }
            }
        } else { // up
            for (var _i = 0; _i < -_delta_row; _i++) {
                var _recycle = pool[pool_rows - 1];
                for (var _r = pool_rows - 1; _r > 0; _r--) pool[_r] = pool[_r - 1];
                pool[0] = _recycle;
                var _world_row = _new_anchor_row + _i;
                for (var _c = 0; _c < pool_cols; _c++) {
                    var _inst = _recycle[_c];
                    var _world_col = _new_anchor_col + _c;
                    var _xy = hex_grid_to_pixel(_world_row, _world_col);
                    _inst.x = _xy[0]; _inst.y = _xy[1];
                    _inst.cell_data = get_world_data(_world_row, _world_col).cell_data;
                }
            }
        }
    }

    // --- Horizontal scroll ---
    if (_delta_col != 0) {
        if (_delta_col > 0) { // right
            for (var _j = 0; _j < _delta_col; _j++) {
                for (var _r = 0; _r < pool_rows; _r++) {
                    var _inst = pool[_r][0];
                    for (var _c = 0; _c < pool_cols - 1; _c++) pool[_r][_c] = pool[_r][_c + 1];
                    pool[_r][pool_cols - 1] = _inst;
                    var _world_row = _new_anchor_row + _r;
                    var _world_col = _new_anchor_col + pool_cols - 1;
                    var _xy = hex_grid_to_pixel(_world_row, _world_col);
                    _inst.x = _xy[0]; _inst.y = _xy[1];
                    _inst.cell_data = get_world_data(_world_row, _world_col).cell_data;
                }
            }
        } else { // left
            for (var _j = 0; _j < -_delta_col; _j++) {
                for (var _r = 0; _r < pool_rows; _r++) {
                    var _inst = pool[_r][pool_cols - 1];
                    for (var _c = pool_cols - 1; _c > 0; _c--) pool[_r][_c] = pool[_r][_c - 1];
                    pool[_r][0] = _inst;
                    var _world_row = _new_anchor_row + _r;
                    var _world_col = _new_anchor_col;
                    var _xy = hex_grid_to_pixel(_world_row, _world_col);
                    _inst.x = _xy[0]; _inst.y = _xy[1];
                    _inst.cell_data = get_world_data(_world_row, _world_col).cell_data;
                }
            }
        }
    }

    anchor_row = _new_anchor_row;
    anchor_col = _new_anchor_col;
}

get_path = function(_start_tile, _goal_tile, _max_distance = undefined) {

    var _open = ds_priority_create();
    var _came_from = ds_map_create();
    var _cost_so_far = ds_map_create();

    ds_priority_add(_open, _start_tile, 0);
    ds_map_add(_cost_so_far, _start_tile, 0);

    var _closest = _start_tile; // fallback if goal not reached
    var _closest_dist = get_hex_distance(_start_tile, _goal_tile);

    while (!ds_priority_empty(_open)) {

        var _current = ds_priority_delete_min(_open);

        // Stop early if beyond max distance
        if (_max_distance != undefined && _max_distance > 0 && get_hex_distance(_start_tile, _current) > _max_distance) {
            break;
        }

        // Reached goal
        if (_current[CellData.Row] == _goal_tile[CellData.Row] &&
            _current[CellData.Col] == _goal_tile[CellData.Col]) {
            _closest = _goal_tile;
            break;
        }

        var _neighbors = get_hex_neighbors(_current);

        for (var _i = 0; _i < array_length(_neighbors); _i++) {
            var _n = _neighbors[_i];
            var _new_cost = _cost_so_far[? _current] + get_tile_cost(_n);

            if (!ds_map_exists(_cost_so_far, _n) || _new_cost < _cost_so_far[? _n]) {
                ds_map_add(_cost_so_far, _n, _new_cost);
                var _priority = _new_cost + get_hex_distance(_n, _goal_tile);
                ds_priority_add(_open, _n, _priority);
                ds_map_add(_came_from, _n, _current);

                // track nearest-to-goal tile
                var _dist = get_hex_distance(_n, _goal_tile);
                if (_dist < _closest_dist) {
                    _closest_dist = _dist;
                    _closest = _n;
                }
            }
        }
    }

    // Reconstruct path (to goal if reached, otherwise to closest)
    var _path = [];
    var _current = _closest;

    while (_current != _start_tile && ds_map_exists(_came_from, _current)) {
        array_insert(_path, 0, _current);
        _current = _came_from[? _current];
    }

    ds_priority_destroy(_open);
    ds_map_destroy(_cost_so_far);
    ds_map_destroy(_came_from);

    return _path;
}

get_hovered_tile = function() {
	hovered_hex = collision_point(mouse_x, mouse_y, obj_hex_tile, true, false);
}

draw_tiles_in_view = function() {
	
	var _tiles_to_draw = [];

    // Collect all visible pool tiles (not world_data, just the pool)
    for (var _r = 0; _r < pool_rows; _r++) {
        for (var _c = 0; _c < pool_cols; _c++) {
            var _inst = pool[_r][_c];
            array_push(_tiles_to_draw, _inst);
        }
    }

    // Sort tiles by Y (then X as tiebreaker)
    array_sort(_tiles_to_draw, function(a, b) {
        if (a.y == b.y) return a.x - b.x;
        return a.y - b.y;
    });

    // Draw them in sorted order
    for (var i = 0; i < array_length(_tiles_to_draw); i++) {
        var _tile = _tiles_to_draw[i];
        with (_tile) draw();
    }
}

on_hex_click = function(_input) {
	
	if (hovered_hex != noone) {
		
		// Check if hovered tile is within movement range
		
		if (!player.is_reachable_tile(hovered_hex.cell_data)) {
			exit;
		}
		

		var _path = get_path(player.current_tile, hovered_hex.cell_data, player.stats.get_stat(LifeformStat.MovePoints));
		show_debug_message(array_length(_path));
	}
}

#endregion

#region Context

context = new InputContext(self, ContextPriority.World, true);
context.add_action(Input.Select, on_hex_click);
context.set_hover_method(get_hovered_tile);

#endregion

#region Events

event_manager_subscribe(Event.GameStart, function() {
	
	// Initialize camera
	init_pool_for_camera();

	// Create player squad
	player = create_lifeform(LifeformType.Human, overworld.world_data[3][2]);
});

event_manager_publish(Event.AddContext, context);

#endregion