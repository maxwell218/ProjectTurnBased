// +---------------------------------------------------------+
// |                                                         |
// |   __       ______   __  __   ______   __  __   ______   |
// |  /\ \     /\  __ \ /\ \_\ \ /\  __ \ /\ \/\ \ /\__  _\  |
// |  \ \ \____\ \  __ \\ \____ \\ \ \/\ \\ \ \_\ \\/_/\ \/  |
// |   \ \_____\\ \_\ \_\\/\_____\\ \_____\\ \_____\  \ \_\  |
// |    \/_____/ \/_/\/_/ \/_____/ \/_____/ \/_____/   \/_/  |
// |                                                         |
// +---------------------------------------------------------+
// class.LayoutContainer

enum LayoutDirection {
    Horizontal,
    Vertical,
}

enum LayoutSizeType {
    Fixed,    // Exact pixel value
    Fill,     // Share of remaining space after Fixed/Content resolved
    Content,  // Defers to node's measure callback
}

function LayoutContainer(_config) constructor {
    __ = {};
    with (__) {
        x         = _config[$ "x"        ] ?? 0;
        y         = _config[$ "y"        ] ?? 0;
        width     = _config[$ "width"    ] ?? 0;
        height    = _config[$ "height"   ] ?? 0;
        direction = _config[$ "direction"] ?? LayoutDirection.Vertical;
        gap       = _config[$ "gap"      ] ?? 0;

        var _m  = _config[$ "margin"] ?? 0;
        margin  = is_real(_m) ? new LayoutMargin(_m) : _m;

        nodes = _config[$ "nodes"] ?? [];
    }

    static get_x      = function() { return __.x;      }
    static get_y      = function() { return __.y;      }
    static get_width  = function() { return __.width;  }
    static get_height = function() { return __.height; }
    static get_nodes  = function() { return __.nodes;  }

    static add_node = function(_node) {
        array_push(__.nodes, _node);
		return self;
    }

    static resize = function(_config) {
        __.x      = _config[$ "x"     ] ?? __.x;
        __.y      = _config[$ "y"     ] ?? __.y;
        __.width  = _config[$ "width" ] ?? __.width;
        __.height = _config[$ "height"] ?? __.height;
        solve();
    }

    // ── solve: measure → place ─────────────────────────────────
    static solve = function() {
        var _is_h  = (__.direction == LayoutDirection.Horizontal);
        var _count = array_length(__.nodes);
        var _m     = __.margin;

        // Inner area after container margin
        var _inner_x = __.x + _m.get_left();
        var _inner_y = __.y + _m.get_top();
        var _inner_w = __.width  - _m.get_horizontal();
        var _inner_h = __.height - _m.get_vertical();

        // ── Pass 1: resolve Fixed and Content on main axis,
        //            resolve cross axis fully,
        //            accumulate consumed space and fill weight ──

        var _gap_total         = max(0, _count - 1) * __.gap;
        var _consumed          = _gap_total;
        var _total_fill_weight = 0;

        var _main_sizes  = array_create(_count, 0);
        var _cross_sizes = array_create(_count, 0);

        for (var _i = 0; _i < _count; _i++) {
            var _node   = __.nodes[_i];
            var _margin = _node.get_margin();

            var _main_desc  = _is_h ? _node.get_size_x() : _node.get_size_y();
            var _cross_desc = _is_h ? _node.get_size_y() : _node.get_size_x();

            var _main_margin  = _is_h ? _margin.get_horizontal() : _margin.get_vertical();
            var _cross_margin = _is_h ? _margin.get_vertical()   : _margin.get_horizontal();

            // Cross axis
            switch (_cross_desc.get_type()) {
                case LayoutSizeType.Fixed:
                    _cross_sizes[_i] = _cross_desc.get_pixels();
                    break;
                case LayoutSizeType.Fill:
                    _cross_sizes[_i] = (_is_h ? _inner_h : _inner_w) - _cross_margin;
                    break;
                case LayoutSizeType.Content:
                    var _measured    = _node.get_content_size();
                    _cross_sizes[_i] = _is_h ? _measured.height : _measured.width;
                    break;
            }

            // Main axis
            switch (_main_desc.get_type()) {
                case LayoutSizeType.Fixed:
                    _main_sizes[_i]  = _main_desc.get_pixels();
                    _consumed       += _main_sizes[_i] + _main_margin;
                    break;
                case LayoutSizeType.Fill:
                    _total_fill_weight += _main_desc.get_weight();
                    _main_sizes[_i]    = -1;   // sentinel — resolved in pass 2
                    _consumed         += _main_margin;
                    break;
                case LayoutSizeType.Content:
                    var _measured    = _node.get_content_size();
                    _main_sizes[_i]  = _is_h ? _measured.width : _measured.height;
                    _consumed       += _main_sizes[_i] + _main_margin;
                    break;
            }
        }

        // ── Pass 2: distribute remaining space to Fill nodes ──
        var _inner_main  = _is_h ? _inner_w : _inner_h;
        var _fill_space  = max(0, _inner_main - _consumed);
        var _fill_per_wt = (_total_fill_weight > 0) ? (_fill_space / _total_fill_weight) : 0;

        for (var _i = 0; _i < _count; _i++) {
            if (_main_sizes[_i] == -1) {
                var _axis = _is_h ? __.nodes[_i].get_size_x() : __.nodes[_i].get_size_y();
				var _weight = _axis.get_weight();
                _main_sizes[_i] = floor(_fill_per_wt * _weight);
            }
        }

        // ── Pass 3: place ──
        var _cursor = 0;
        for (var _i = 0; _i < _count; _i++) {
            var _node   = __.nodes[_i];
            var _margin = _node.get_margin();

            var _main_start  = _is_h ? _margin.get_left() : _margin.get_top();
            var _main_end    = _is_h ? _margin.get_right() : _margin.get_bottom();
            var _cross_start = _is_h ? _margin.get_top()  : _margin.get_left();

            var _w = _is_h ? _main_sizes[_i]  : _cross_sizes[_i];
            var _h = _is_h ? _cross_sizes[_i] : _main_sizes[_i];

            var _nx = _is_h
                ? (_inner_x + _cursor + _main_start)
                : (_inner_x + _cross_start);
            var _ny = _is_h
                ? (_inner_y + _cross_start)
                : (_inner_y + _cursor + _main_start);

            _node.apply_resolved(_nx, _ny, _w, _h);

            _cursor += _main_sizes[_i] + _main_start + _main_end
                     + ((_i < _count - 1) ? __.gap : 0);
        }
    }
}