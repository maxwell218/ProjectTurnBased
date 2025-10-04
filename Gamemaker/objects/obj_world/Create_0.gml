/// @description Create all world components

#macro WORLD_WIDTH 5
#macro WORLD_HEIGHT 5

#macro HEX_WIDTH sprite_get_width(spr_hex_tile)
#macro HEX_HEIGHT sprite_get_height(spr_hex_tile)

// Define terrain types
enum TerrainType {
	Plain,
	Mountain,
	Forest,
	Lake,
	Town,
	City,
	Junkyard,
	Lab,
	Bunker,
	Last
}

// Create overworld
overworld = new Overworld();

// TODO Create player squad
player = new Lifeform(LifeformType.Human, overworld.world_data[1][1]);

// Array of points to keep track of the closest polygon's vertices
verts = [];

#region Methods

create_hex_vertices = function(_x, _y) {
    var verts = array_create(6);

    // Vertices clockwise starting from top-left corner
    verts[0] = [_x + HEX_WIDTH * 0.25, _y];               // top-left
    verts[1] = [_x + HEX_WIDTH * 0.75, _y];               // top-right
    verts[2] = [_x + HEX_WIDTH, _y + HEX_HEIGHT/2];       // right
    verts[3] = [_x + HEX_WIDTH * 0.75, _y + HEX_HEIGHT];  // bottom-right
    verts[4] = [_x + HEX_WIDTH * 0.25, _y + HEX_HEIGHT];  // bottom-left
    verts[5] = [_x, _y + HEX_HEIGHT/2];                   // left

    return verts;
}

oddq_to_pixel_center = function(_col, _row) {
    var _cx = _col * (HEX_WIDTH * 3/4) + HEX_WIDTH/2;
    var _cy = _row * HEX_HEIGHT + HEX_HEIGHT/2 + (_col mod 2) * (HEX_HEIGHT/2);
    return [_cx, _cy];
}

pixel_to_hex_distance = function(_px, _py) {

    // Step 1: candidate odd-q hex from bounding-box
    var _col = floor(_px / (HEX_WIDTH * 3/4));
    var _row = floor((_py - (_col mod 2) * (HEX_HEIGHT / 2)) / HEX_HEIGHT);

    // Step 2: collect candidate hex + neighbors
    var _candidates = [
        [_col, _row],
        [_col-1, _row-1], [_col-1, _row], [_col-1, _row+1],
        [_col+1, _row-1], [_col+1, _row], [_col+1, _row+1]
    ];

    var _closest_col = clamp(_col, 0, WORLD_WIDTH-1);
    var _closest_row = clamp(_row, 0, WORLD_HEIGHT-1);
    var _min_dist = infinity;

    for (var i = 0; i < array_length(_candidates); i++) {
        var _c = _candidates[i];
        var _c_col = _c[0];
        var _c_row = _c[1];

        // skip out-of-bounds hexes
        if (_c_col < 0 || _c_row < 0 || _c_col >= WORLD_WIDTH || _c_row >= WORLD_HEIGHT) continue;

        var _center = oddq_to_pixel_center(_c_col, _c_row);
        var _d = point_distance(_px, _py, _center[0], _center[1]);

        if (_d < _min_dist) {
            _min_dist = _d;
            _closest_col = _c_col;
            _closest_row = _c_row;
        }
    }

    // Final clamp to ensure never out of bounds
    _closest_col = clamp(_closest_col, 0, WORLD_WIDTH-1);
    _closest_row = clamp(_closest_row, 0, WORLD_HEIGHT-1);

    return [_closest_col, _closest_row];
}

point_in_polygon = function(_px, _py, _verts) {
    var _inside = false;
    var _n = array_length(_verts);
    
    // Loop through each edge
    for (var _i = 0; _i < _n; _i++) {
        var _j = (_i + _n - 1) mod _n; // previous vertex, wraps around
        var _xi = _verts[_i][0];
        var _yi = _verts[_i][1];
        var _xj = _verts[_j][0];
        var _yj = _verts[_j][1];

        // Ray-casting test
        if (((_yi > _py) != (_yj > _py)) &&
            (_px < (_xj - _xi) * (_py - _yi) / (_yj - _yi) + _xi)) {
            _inside = !_inside;
        }
    }
    
    return _inside;
}

#endregion