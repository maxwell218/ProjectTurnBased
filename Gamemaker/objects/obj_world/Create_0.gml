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

// For debugging, keeps a tile draw call count
tiles_draw_count = 0;

cube_neighbors = [
    [+1, -1, 0], [+1, 0, -1], [0, +1, -1],
    [-1, +1, 0], [-1, 0, +1], [0, -1, +1]
];

// Create player squad
// player = new Lifeform(LifeformType.Human, overworld.world_data[1][1]);

// Contains the hovered hexagon object
hovered_hex = noone;

#region Methods

/// @description Returns all neighbor instances of an hex
get_hex_neighbors = function(_hex) {
	
	var _cube_x = _hex.cell_data[CellData.CubeX];
	var _cube_y = _hex.cell_data[CellData.CubeY];
	
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

hex_grid_to_pixel = function(_row, _col) {
    var _x = _col * COL_SPACING;
    var _y = _row * HEX_HEIGHT + ((_col mod 2) * HALF_HEX_HEIGHT);
    return [_x, _y];
}

pixel_to_hex_grid = function(_px, _py) {
    var _col = floor(_px / (HEX_WIDTH * 0.75));  // base column guess
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

    if (_new_anchor_row == anchor_row && _new_anchor_col == anchor_col) return;

    for (var _i = 0; _i < pool_rows; _i++) {
        for (var _j = 0; _j < pool_cols; _j++) {
            var _inst = pool[_i][_j];

            var _world_row = _new_anchor_row + _i;
            var _world_col = _new_anchor_col + _j;

            var _xy = hex_grid_to_pixel(_world_row, _world_col);
            _inst.x = _xy[0];
            _inst.y = _xy[1];

            _inst.cell_data = get_world_data(_world_row, _world_col).cell_data;
        }
    }

    anchor_row = _new_anchor_row;
    anchor_col = _new_anchor_col;
}

#endregion

init_pool_for_camera();