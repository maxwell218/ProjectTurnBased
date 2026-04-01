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
	Fixed,		// Exact pixel value
	Fill,		// Share of remaining space after Fixed/Content resolved 
	Content,	// Defers to node's measure callback 
}

function LayoutContainer(_config) constructor {
	// TODO Nomenclature
	
    __ = {};
    with (__) {
        x         = _config[$ "x"] ?? 0;
        y         = _config[$ "y"] ?? 0;
        width     = _config[$ "width"] ?? 0;
        height    = _config[$ "height"] ?? 0;
        direction = _config[$ "direction"] ?? LayoutDirection.Vertical;

        var _m = _config[$ "margin"] ?? 0;
        margin = is_real(_m) ? new LayoutMargin({ top: _m, right: _m, bottom: _m, left: _m }) : _m;

        nodes = _config[$ "nodes"] ?? [];
    }

    #region Getters

    static get_x = function() { return __.x; }
    static get_y = function() { return __.y; }
    static get_width = function() { return __.width; }
    static get_height = function() { return __.height; }
    static get_nodes = function() { return __.nodes; }
	static get_visual_leading = function(_parent_is_h) {
	    var _count = array_length(__.nodes);
	    if (_count <= 0) return 0;

	    // Parent is horizontal: asking about this container's LEFT edge
	    if (_parent_is_h) {
	        if (__.direction == LayoutDirection.Horizontal) {
	            return __.nodes[0].get_visual_leading(true);
	        } else {
	            var _max_left = 0;
	            for (var _i = 0; _i < _count; _i++) {
	                _max_left = max(_max_left, __.nodes[_i].get_visual_leading(true));
	            }
	            return _max_left;
	        }
	    }

	    // Parent is vertical: asking about this container's TOP edge
	    if (__.direction == LayoutDirection.Vertical) {
	        return __.nodes[0].get_visual_leading(false);
	    } else {
	        var _max_top = 0;
	        for (var _i = 0; _i < _count; _i++) {
	            _max_top = max(_max_top, __.nodes[_i].get_visual_leading(false));
	        }
	        return _max_top;
	    }
	}
	static get_visual_trailing = function(_parent_is_h) {
	    var _count = array_length(__.nodes);
	    if (_count <= 0) return 0;

	    // Parent is horizontal: asking about this container's RIGHT edge
	    if (_parent_is_h) {
	        if (__.direction == LayoutDirection.Horizontal) {
	            return __.nodes[_count - 1].get_visual_trailing(true);
	        } else {
	            var _max_right = 0;
	            for (var _i = 0; _i < _count; _i++) {
	                _max_right = max(_max_right, __.nodes[_i].get_visual_trailing(true));
	            }
	            return _max_right;
	        }
	    }

	    // Parent is vertical: asking about this container's BOTTOM edge
	    if (__.direction == LayoutDirection.Vertical) {
	        return __.nodes[_count - 1].get_visual_trailing(false);
	    } else {
	        var _max_bottom = 0;
	        for (var _i = 0; _i < _count; _i++) {
	            _max_bottom = max(_max_bottom, __.nodes[_i].get_visual_trailing(false));
	        }
	        return _max_bottom;
	    }
	}

    #endregion

    #region Public

    static add_node = function(_node) {
        array_push(__.nodes, _node);
        return self;
    }

    static resize = function(_config) {
        __.x      = _config[$ "x"]      ?? __.x;
        __.y      = _config[$ "y"]      ?? __.y;
        __.width  = _config[$ "width"]  ?? __.width;
        __.height = _config[$ "height"] ?? __.height;
        solve();
    }

    static solve = function() {
        var _count = array_length(__.nodes);
        if (_count <= 0) return;

        var _is_h = (__.direction == LayoutDirection.Horizontal);

        var _container_margin = __.margin;
        var _inner_x = __.x + _container_margin.get_left();
        var _inner_y = __.y + _container_margin.get_top();
        var _inner_w = max(0, __.width  - _container_margin.get_horizontal());
        var _inner_h = max(0, __.height - _container_margin.get_vertical());

        var _inner_main  = _is_h ? _inner_w : _inner_h;
        var _inner_cross = _is_h ? _inner_h : _inner_w;

        var _main_sizes   = array_create(_count, 0);
        var _cross_sizes  = array_create(_count, 0);
        var _seam_overlap = array_create(max(0, _count - 1), 0);

        var _consumed_main = 0;
        var _total_fill_weight = 0;
        var _fill_indices = [];

        // -------------------------------------------------
        // PASS 1
        // Resolve cross sizes.
        // Resolve main sizes for Fixed / Content.
        // Defer Fill on main axis.
        // -------------------------------------------------

        for (var _i = 0; _i < _count; _i++) {
            var _node   = __.nodes[_i];
            var _margin = _node.get_margin();

            var _size_main  = _is_h ? _node.get_size_x() : _node.get_size_y();
            var _size_cross = _is_h ? _node.get_size_y() : _node.get_size_x();

            var _main_margin_start = _is_h ? _margin.get_left()  : _margin.get_top();
            var _main_margin_end   = _is_h ? _margin.get_right() : _margin.get_bottom();
            var _main_margin_sum   = _main_margin_start + _main_margin_end;

            var _cross_margin_sum  = _is_h ? _margin.get_vertical() : _margin.get_horizontal();
            var _available_cross   = max(0, _inner_cross - _cross_margin_sum);

            // Cross axis first
            switch (_size_cross.get_type()) {
                case LayoutSizeType.Fixed:
                    _cross_sizes[_i] = max(0, _size_cross.get_pixels());
                    break;

                case LayoutSizeType.Fill:
                    _cross_sizes[_i] = _available_cross;
                    break;

                case LayoutSizeType.Content:
                    var _measured_cross = _node.get_content_size(
                        _is_h ? 0 : _available_cross,
                        _is_h ? _available_cross : 0
                    );

                    _cross_sizes[_i] = max(0, _is_h ? _measured_cross.height : _measured_cross.width);
                    break;
            }

            // Main axis
            switch (_size_main.get_type()) {
                case LayoutSizeType.Fixed:
                    _main_sizes[_i] = max(0, _size_main.get_pixels());
                    _consumed_main += _main_sizes[_i] + _main_margin_sum;
                    break;

                case LayoutSizeType.Content:
                    var _offered_cross = _cross_sizes[_i];
                    var _measured_main = _node.get_content_size(
                        _is_h ? 0 : _offered_cross,
                        _is_h ? _offered_cross : 0
                    );

                    _main_sizes[_i] = max(0, _is_h ? _measured_main.width : _measured_main.height);
                    _consumed_main += _main_sizes[_i] + _main_margin_sum;
                    break;

                case LayoutSizeType.Fill:
                    _main_sizes[_i] = -1;
                    _consumed_main += _main_margin_sum;
                    _total_fill_weight += max(0, _size_main.get_weight());
                    array_push(_fill_indices, _i);
                    break;
            }
        }

        // -------------------------------------------------
        // PASS 2
        // Compute seam overlaps between adjacent OUTER borders.
        // -------------------------------------------------

       for (var _i = 0; _i < _count - 1; _i++) {
		    var _a_trailing = __.nodes[_i].get_visual_trailing(_is_h);
		    var _b_leading  = __.nodes[_i + 1].get_visual_leading(_is_h);

		    var _overlap = min(_a_trailing, _b_leading);

		    _seam_overlap[_i] = _overlap;
		    _consumed_main -= _overlap;
		}

        // -------------------------------------------------
        // PASS 3
        // Distribute remaining main size to Fill items.
        // -------------------------------------------------

        var _remaining_main = max(0, _inner_main - _consumed_main);

        if (array_length(_fill_indices) > 0 && _total_fill_weight > 0) {
            var _assigned = 0;
            var _fill_count = array_length(_fill_indices);

            for (var _j = 0; _j < _fill_count; _j++) {
                var _index = _fill_indices[_j];
                var _node_fill = __.nodes[_index];
                var _size_fill = _is_h ? _node_fill.get_size_x() : _node_fill.get_size_y();
                var _weight = max(0, _size_fill.get_weight());

                var _share = floor((_remaining_main * _weight) / _total_fill_weight);
                _main_sizes[_index] = _share;
                _assigned += _share;
            }

            var _remainder = _remaining_main - _assigned;
            for (var _r = 0; _r < _remainder; _r++) {
                var _target = _fill_indices[_r mod _fill_count];
                _main_sizes[_target] += 1;
            }
        } else {
            for (var _k = 0; _k < array_length(_fill_indices); _k++) {
                _main_sizes[_fill_indices[_k]] = 0;
            }
        }

        // -------------------------------------------------
        // PASS 4
        // Position.
        // Cursor advances by full footprint minus seam overlap
        // with the next item.
        // -------------------------------------------------

        var _cursor_main = 0;

        for (var _i = 0; _i < _count; _i++) {
            var _node   = __.nodes[_i];
            var _margin = _node.get_margin();
            var _fmt    = _node.get_element_format();

            var _is_outer = (_fmt != undefined) && (_fmt.get_border_mode() == UIBorderMode.Outer);

            var _bl = _is_outer ? _fmt.get_border_left()   : 0;
            var _br = _is_outer ? _fmt.get_border_right()  : 0;
            var _bt = _is_outer ? _fmt.get_border_top()    : 0;
            var _bb = _is_outer ? _fmt.get_border_bottom() : 0;

            var _main_margin_start  = _is_h ? _margin.get_left()  : _margin.get_top();
            var _main_margin_end    = _is_h ? _margin.get_right() : _margin.get_bottom();
            var _cross_margin_start = _is_h ? _margin.get_top()   : _margin.get_left();

            var _slot_w = _is_h ? _main_sizes[_i]  : _cross_sizes[_i];
            var _slot_h = _is_h ? _cross_sizes[_i] : _main_sizes[_i];

            var _resolved_w = max(0, _slot_w - _bl - _br);
            var _resolved_h = max(0, _slot_h - _bt - _bb);

            var _resolved_x;
            var _resolved_y;

            if (_is_h) {
                _resolved_x = _inner_x + _cursor_main + _main_margin_start + _bl;
                _resolved_y = _inner_y + _cross_margin_start + _bt;
            } else {
                _resolved_x = _inner_x + _cross_margin_start + _bl;
                _resolved_y = _inner_y + _cursor_main + _main_margin_start + _bt;
            }

            _node.apply_resolved(_resolved_x, _resolved_y, _resolved_w, _resolved_h);

            var _advance = _main_margin_start + _main_sizes[_i] + _main_margin_end;

			if (_i < _count - 1) {
			    _advance -= _seam_overlap[_i];
			}

			_cursor_main += _advance;
		}
    }

    #endregion
}