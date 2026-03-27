// +-------------------+
// |                   |
// |   __  __   __     |
// |  /\ \/\ \ /\ \    |
// |  \ \ \_\ \\ \ \   |
// |   \ \_____\\ \_\  |
// |    \/_____/ \/_/  |
// |                   |
// +-------------------+
// class.UIFormat

enum UIBorderMode {
    None,           // No shared borders; each item is fully self-contained
    SharedEdge,     // Adjacent items share one border edge (rendered by the leading
                    // item only — trailing item skips its leading border)
    OuterOnly,      // Only the outermost list boundary has a border; items have none
}

function UIFormat(_config = {}) constructor {
	// TODO Refactor + nomenclature
    content_inset = _config[$ "content_inset"] ?? 0;
    item_spacing  = _config[$ "item_spacing" ] ?? 0;
    border_mode   = _config[$ "border_mode"  ] ?? UIBorderMode.None;
	
    /// Returns the main-axis offset where the first item should be placed.
    /// This equals content_inset — never includes item_spacing.
    static first_item_offset = function() {
        return content_inset;
    }

    /// Returns the main-axis offset where item _i should be placed,
    /// given that every item has the same _item_size on the main axis.
    ///
    /// For heterogeneous sizes, accumulate manually using gap_before(_i).
    static item_offset = function(_i, _item_size) {
        return content_inset + _i * (_item_size + item_spacing);
    }

    /// Returns the gap to insert before item _i.
    ///   _i == 0 → no gap (outer inset is handled separately)
    ///   _i  > 0 → item_spacing
    static gap_before = function(_i) {
        return (_i > 0) ? item_spacing : 0;
    }

    /// Returns the total content extent for _count items each of _item_size.
    /// Formula: inset + N*item_size + (N-1)*spacing + inset
    ///
    /// For heterogeneous sizes, sum item sizes separately and call
    ///   content_size_for_sum(_count, _total_item_size) instead.
    static content_size_for = function(_count, _item_size) {
        if (_count <= 0) return content_inset * 2;
        return content_inset * 2 + _count * _item_size + max(0, _count - 1) * item_spacing;
    }

    /// Same as content_size_for but accepts the pre-summed total of all item
    /// sizes (for heterogeneous item lists).
    static content_size_for_sum = function(_count, _total_item_size) {
        if (_count <= 0) return content_inset * 2;
        return content_inset * 2 + _total_item_size + max(0, _count - 1) * item_spacing;
    }

    static available_cross = function(_list_cross) {
		/// Returns usable cross-axis extent after subtracting both insets.
        return _list_cross - content_inset * 2;
    }

    /// Returns true when item _i should suppress its own leading border
    /// because the previous item's trailing border serves as the shared edge.
    /// Only relevant under UIBorderMode.SharedEdge.
    static suppress_leading_border = function(_i) {
        return (border_mode == UIBorderMode.SharedEdge && _i > 0);
    }

    /// Returns true when item borders should be omitted entirely.
    /// Callers render the outer list boundary themselves under OuterOnly.
    static suppress_item_borders = function() {
        return (border_mode == UIBorderMode.OuterOnly);
    }
}