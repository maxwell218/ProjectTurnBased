// +---------------------------------------------------------+
// |                                                         |
// |   __       ______   __  __   ______   __  __   ______   |
// |  /\ \     /\  __ \ /\ \_\ \ /\  __ \ /\ \/\ \ /\__  _\  |
// |  \ \ \____\ \  __ \\ \____ \\ \ \/\ \\ \ \_\ \\/_/\ \/  |
// |   \ \_____\\ \_\ \_\\/\_____\\ \_____\\ \_____\  \ \_\  |
// |    \/_____/ \/_/\/_/ \/_____/ \/_____/ \/_____/   \/_/  |
// |                                                         |
// +---------------------------------------------------------+
// class.Layout

enum LayoutAxis {
    Row,    // Children arranged horizontally
    Column, // Children arranged vertically
}

function Layout(_config) : UIParent(_config) constructor {
	var _self = self;

    #region Config

    // Private
    with (__) {
        axis          = _config[$ "axis"] ?? LayoutAxis.Column;
        is_dirty      = false;
        dirty_node    = undefined;
        parent_layout = undefined;
    }

    #endregion
    #region Nodes

    // Public
    static add_node = function(_config) {
        var _node = new LayoutNode(_config, self);
        array_push(__.children, _node);
        return self;
    }

    #endregion
    #region Layout Interface

    // Public
    static set_parent_layout = function(_layout) {
        __.parent_layout = _layout;
    }

    static get_content_size = function() {
        return __measure_content();
    }

    static resize = function(_config) {
        __.x      = _config[$ "x"     ] ?? __.x;
        __.y      = _config[$ "y"     ] ?? __.y;
        __.width  = _config[$ "width" ] ?? __.width;
        __.height = _config[$ "height"] ?? __.height;
        resolve();
    }

    #endregion
    #region Dirty

    // Public
    static mark_dirty = function(_node = undefined) {
        __.is_dirty = true;
        // Track the first node that triggered dirty for reference
        if (_node != undefined && __.dirty_node == undefined) {
            __.dirty_node = _node;
        }
        if (__.parent_layout != undefined) {
            __.parent_layout.mark_dirty(self);
        }
    }

    #endregion
    #region Activate / Deactivate

    // Public
    static activate = function() {
        if (__.parent_layout != undefined) {
            show_error("Cannot activate a nested Layout directly, its lifecycle is managed by its parent Layout.", true);
        }
        if (__.is_dirty) {
            resolve();
        }
        event_manager_publish(Event.AddUIRoot, self);
        event_manager_subscribe(Event.WindowResized, on_window_resize);
    }

    static deactivate = function() {
        if (__.parent_layout != undefined) {
            show_error("Cannot deactivate a nested Layout directly, its lifecycle is managed by its parent Layout.", true);
        }
        event_manager_publish(Event.RemoveUIRoot, self);
        event_manager_unsubscribe(Event.WindowResized);
    }

    static on_window_resize = function(_data) {
        __.width  = _data.width;
        __.height = _data.height;
        resolve();
    }

    #endregion
    #region Resolve

    // Public
    static resolve = function() {
        var _is_row          = (__.axis == LayoutAxis.Row);
        var _count           = array_length(__.children);
        var _main_available  = _is_row ? __.width  : __.height;
        var _cross_available = _is_row ? __.height : __.width;
        var _fill_total      = 0;

        // --- Pass 1: Fixed and margins ---
        // Subtract fixed sizes and all margins from available space,
        // accumulate fill shares

        for (var _i = 0; _i < _count; _i++) {
            var _node        = __.children[_i];
            var _margin      = _node.get_margin();
            var _main_size   = _is_row ? _node.get_width() : _node.get_height();
            var _main_margin = _is_row ? _margin.get_horizontal() : _margin.get_vertical();

            _main_available -= _main_margin;

            if (instanceof(_main_size) == "LayoutSizeFixed") {
                _main_available -= _main_size.get_px();
            } else if (instanceof(_main_size) == "LayoutSizeFill") {
                _fill_total += _main_size.get_share();
            }
        }

        // --- Pass 2: Hug nodes ---
        // Fetch content size from each hug element, subtract from remaining space

        for (var _i = 0; _i < _count; _i++) {
            var _node      = __.children[_i];
            var _main_size = _is_row ? _node.get_width() : _node.get_height();

            if (instanceof(_main_size) == "LayoutSizeHug") {
                var _content     = _node.get_element().get_content_size();
                _main_available -= _is_row ? _content.width : _content.height;
            }
        }

        // --- Pass 3: Compute fill unit ---

        var _fill_unit = (_fill_total > 0) ? (_main_available / _fill_total) : 0;

        // --- Commit: position and resize only changed nodes ---

        var _cursor = _is_row ? __.x : __.y;

        for (var _i = 0; _i < _count; _i++) {
            var _node        = __.children[_i];
            var _margin      = _node.get_margin();
            var _main_size   = _is_row ? _node.get_width()  : _node.get_height();
            var _cross_size  = _is_row ? _node.get_height() : _node.get_width();
            var _element     = _node.get_element();

            var _main_margin_start  = _is_row ? _margin.get_left()    : _margin.get_top();
            var _main_margin_end    = _is_row ? _margin.get_right()   : _margin.get_bottom();
            var _cross_margin_start = _is_row ? _margin.get_top()     : _margin.get_left();
            var _cross_margin_end   = _is_row ? _margin.get_bottom()  : _margin.get_right();

            // Gather content size once per node
            var _needs_content  = (instanceof(_main_size) == "LayoutSizeHug" || instanceof(_cross_size) == "LayoutSizeHug");
            var _content        = _needs_content ? _element.get_content_size() : undefined;
            var _main_content   = (_content != undefined) ? (_is_row ? _content.width  : _content.height) : 0;
            var _cross_content  = (_content != undefined) ? (_is_row ? _content.height : _content.width)  : 0;

            var _resolved_main  = _main_size.resolve(_fill_unit, _main_content);
            var _resolved_cross = _cross_size.resolve(_fill_unit, _cross_available - _cross_margin_start - _cross_margin_end);

            var _node_x = _is_row ? (_cursor + _main_margin_start) : (__.x + _cross_margin_start);
            var _node_y = _is_row ? (__.y    + _cross_margin_start) : (_cursor + _main_margin_start);
            var _node_w = _is_row ? _resolved_main  : _resolved_cross;
            var _node_h = _is_row ? _resolved_cross : _resolved_main;

            _cursor += _resolved_main + _main_margin_start + _main_margin_end;

            // Only call resize if resolved values changed
            var _changed = (_node_x != _node.get_resolved_x())
                        || (_node_y != _node.get_resolved_y())
                        || (_node_w != _node.get_resolved_width())
                        || (_node_h != _node.get_resolved_height());

            if (_changed) {
                _node.set_resolved(_node_x, _node_y, _node_w, _node_h);
                _element.resize({
                    x:      _node_x,
                    y:      _node_y,
                    width:  _node_w,
                    height: _node_h,
                });
            }

            _node.clear_dirty();
        }

        // Reset layout dirty state
        __.is_dirty    = false;
        __.dirty_node  = undefined;
    }

    #endregion
    #region Measure

    // Private
    with (__) {
        static __measure_content = function() {
            var _is_row = (__.axis == LayoutAxis.Row);
            var _main   = 0;
            var _cross  = 0;
            var _count  = array_length(__.children);

            for (var _i = 0; _i < _count; _i++) {
                var _node         = __.children[_i];
                var _margin       = _node.get_margin();
                var _main_size    = _is_row ? _node.get_width()  : _node.get_height();
                var _cross_size   = _is_row ? _node.get_height() : _node.get_width();
                var _main_margin  = _is_row ? _margin.get_horizontal() : _margin.get_vertical();
                var _cross_margin = _is_row ? _margin.get_vertical()   : _margin.get_horizontal();

                var _needs_content = (instanceof(_main_size) == "LayoutSizeHug" || instanceof(_cross_size) == "LayoutSizeHug");
                var _content       = _needs_content ? _node.get_element().get_content_size() : undefined;
                var _main_content  = (_content != undefined) ? (_is_row ? _content.width  : _content.height) : 0;
                var _cross_content = (_content != undefined) ? (_is_row ? _content.height : _content.width)  : 0;

                _main  += _main_margin  + _main_size.resolve(0, _main_content);
                _cross  = max(_cross, _cross_margin + _cross_size.resolve(0, _cross_content));
            }

            return {
                width:  _is_row ? _main  : _cross,
                height: _is_row ? _cross : _main,
            };
        }
    }

    #endregion
    #region Cleanup

    // Public
    static cleanup = function() {
        // nothing to free yet — surfaces live on individual UI elements
    }

    #endregion
}