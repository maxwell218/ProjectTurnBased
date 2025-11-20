/// @description Create all world components
#macro WORLD_HEIGHT 20
#macro WORLD_WIDTH 20

#macro HEX_HEIGHT sprite_get_height(spr_hex_tile)
#macro HEX_WIDTH sprite_get_width(spr_hex_tile)

#macro BUFFER_ROWS 2
#macro BUFFER_COLS 2

#macro COL_SPACING HEX_WIDTH * 3/4
#macro HALF_HEX_HEIGHT HEX_HEIGHT div 2
#macro HALF_HEX_WIDTH HEX_WIDTH div 2

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

#region Methods

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
			array_push(_neighbors, overworld.world_data[_coords[0]][_coords[1]]);
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
	
	pool_rows = min(_visible_rows, WORLD_HEIGHT);
	pool_cols = min(_visible_cols, WORLD_WIDTH);

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

            _inst.cell_data = get_world_data(_world_row, _world_col);

            pool[_i][_j] = _inst;
        }
    }
}

reposition_pool = function() {
	
    // --- Camera -> new anchor
    var _cam_x = camera_get_view_x(view_camera[0]);
    var _cam_y = camera_get_view_y(view_camera[0]);
    var _new_anchor = pixel_to_hex_grid(_cam_x, _cam_y);
    var _new_anchor_row = clamp(_new_anchor[0] - 1, 0, max(0, WORLD_HEIGHT - pool_rows));
    var _new_anchor_col = clamp(_new_anchor[1] - 1, 0, max(0, WORLD_WIDTH - pool_cols));

    if (_new_anchor_row == anchor_row && _new_anchor_col == anchor_col) return;

    // --- Bounds
    var _old_r0 = anchor_row, _old_c0 = anchor_col;
    var _new_r0 = _new_anchor_row, _new_c0 = _new_anchor_col;
    var _old_r1 = _old_r0 + pool_rows - 1, _old_c1 = _old_c0 + pool_cols - 1;
    var _new_r1 = _new_r0 + pool_rows - 1, _new_c1 = _new_c0 + pool_cols - 1;

    // --- Overlap region
    var _ov_r0 = max(_old_r0, _new_r0), _ov_c0 = max(_old_c0, _new_c0);
    var _ov_r1 = min(_old_r1, _new_r1), _ov_c1 = min(_old_c1, _new_c1);
    var _has_overlap = (_ov_r1 >= _ov_r0) && (_ov_c1 >= _ov_c0);

    // --- Collect recyclable instances
    var _recyclables = [];
    for (var _i = 0; _i < pool_rows; _i++) {
        for (var _j = 0; _j < pool_cols; _j++) {
            var _r = _old_r0 + _i, _c = _old_c0 + _j;
            if (_r < _new_r0 || _r > _new_r1 || _c < _new_c0 || _c > _new_c1) {
                array_push(_recyclables, pool[_i][_j]);
            }
        }
    }

    // --- Create new pool
    var _new_pool = array_create(pool_rows);
    for (var _i = 0; _i < pool_rows; _i++) _new_pool[_i] = array_create(pool_cols);
    var _recycle_i = 0;

    // --- Fill new pool
    for (var _i = 0; _i < pool_rows; _i++) {
        for (var _j = 0; _j < pool_cols; _j++) {
            var _wr = _new_r0 + _i, _wc = _new_c0 + _j;

            // Reuse overlapping instance if inside both old and new regions
            if (_has_overlap && _wr >= _ov_r0 && _wr <= _ov_r1 && _wc >= _ov_c0 && _wc <= _ov_c1) {
                var _old_i = _wr - _old_r0, _old_j = _wc - _old_c0;
                _new_pool[_i][_j] = pool[_old_i][_old_j];
                continue;
            }

            // Otherwise recycle an old instance
            var _inst = _recyclables[_recycle_i++];
            var _xy = hex_grid_to_pixel(_wr, _wc);
            _inst.x = _xy[0];
            _inst.y = _xy[1];
			_inst.cell_data = get_world_data(_wr, _wc);

            _new_pool[_i][_j] = _inst;
        }
    }

    pool = _new_pool;
    anchor_row = _new_anchor_row;
    anchor_col = _new_anchor_col;
}

update_tile_pool = function() {
	
    var _cam = view_camera[0];
    var _vx  = camera_get_view_x(_cam);
    var _vy  = camera_get_view_y(_cam);
    var _grid = pixel_to_hex_grid(_vx, _vy);

    var _new_row = clamp(_grid[0] - 1, 0, WORLD_HEIGHT - pool_rows);
    var _new_col = clamp(_grid[1] - 1, 0, WORLD_WIDTH - pool_cols);

    // Check how far the camera moved in tile space
    var _dr = abs(_new_row - anchor_row);
    var _dc = abs(_new_col - anchor_col);

    // If the jump exceeds the pool, just re-init (teleport case)
    if (_dr >= pool_rows || _dc >= pool_cols) {
        init_pool_for_camera();
    } else {
        reposition_pool(); // Smooth scroll case
    }
}

get_path = function(_start_tile, _goal_tile, _max_distance = undefined) {

    var _open = ds_priority_create();
    var _came_from = ds_map_create();
    var _cost_so_far = ds_map_create();

    ds_priority_add(_open, _start_tile, 0);
    ds_map_add(_cost_so_far, _start_tile, 0);

    var _closest = _start_tile; // Fallback if goal not reached
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

move_lifeform_group = function(_lifeform_group, _next_tile) {
	
	// Remove group from their old tile
	var _old_row = _lifeform_group.current_tile[CellData.Row];
	var _old_col = _lifeform_group.current_tile[CellData.Col];
	
	var _old_tile = get_world_data(_old_row, _old_col);
	
	// Find the group on the tile's lifeform array
	var _lifeform_group_count = array_length(_old_tile[CellData.LifeformGroups]);
	for (var _i = 0; _i < _lifeform_group_count; _i++) {
		
		var _group = _old_tile[CellData.LifeformGroups][_i];
		
		// Match found
		if (_group.group_id == _lifeform_group.group_id) {
			array_delete(_old_tile[CellData.LifeformGroups], _i, 1);
		}
	}
	
	array_push(_next_tile[CellData.LifeformGroups], _lifeform_group);
	
	// Move group on position map
	lifeform_group_positions[? _lifeform_group.group_id] = _next_tile;
}

get_hovered_tile = function() {
	
	hovered_hex = collision_point(mouse_x, mouse_y, obj_hex_tile, true, false);
}

on_hex_click = function(_inputs) {
	
	// TODO Send ui button state as well (Scout, Run, etc.)
	if (_inputs[Input.Select] && hovered_hex != noone) {
		
		event_manager_publish(Event.WorldCellSelected, hovered_hex.cell_data);
	}
	
	if (_inputs[Input.Up]) {
		show_debug_message("test");	
	}
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

#endregion

#region Variables

// Create overworld
overworld = new Overworld();

// Cube neighbors lookup array
cube_neighbors = [
    [+1, -1, 0], [+1, 0, -1], [0, +1, -1],
    [-1, +1, 0], [-1, 0, +1], [0, -1, +1]
];

// Contains the hovered hexagon object
hovered_hex = noone;

// Contains the position of all groups (id -> cell_data)
lifeform_group_positions = ds_map_create();

// Contains structs of static spawns
lifeform_spawns = [];

// Pooled hexes variables
pool = [];
pool_rows = 0;
pool_cols = 0;
anchor_row = 0;
anchor_col = 0;

#endregion

#region Context

context = new InputContext(self, ContextPriority.World, true);
context.add_action_group([Input.Select], on_hex_click, 0, true);
context.set_hover_method(get_hovered_tile);

#endregion

#region Events

event_manager_subscribe(Event.GameNew, function() {
	
	// TODO Initialise factions
	
	// Initialise spawns
	array_push(lifeform_spawns, new StaticSpawn(2, 5));
	array_push(lifeform_spawns, new StaticSpawn(10, 12));
	
	// Initialize camera
	init_pool_for_camera();
	
	event_manager_publish(Event.WorldCreated);
});

event_manager_subscribe(Event.LifeformGroupCreated, function(_lifeform_group) {
	
	// Get a valid spawn
	_spawn_cell = lifeform_spawns[irandom_range(0, array_length(lifeform_spawns) - 1)];
	
	var _world_cell = get_world_data(_spawn_cell.row, _spawn_cell.col);
	
	if (_world_cell == undefined) {
		show_debug_message("Invalid spawn for lifeform group: " + string(_lifeform_group.group_id));
		
		ds_map_delete(global.lifeform_controller.lifeform_groups, _lifeform_group.group_id);
		_lifeform_group.destroy();
		delete _lifeform_group;
		return;
	}
	
	// Initialize group instances and their position on our ds map
	_lifeform_group.init(_world_cell);
	ds_map_add(lifeform_group_positions, _lifeform_group.group_id, _world_cell);
});

event_manager_publish(Event.AddContext, context);

#endregion