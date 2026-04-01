// +-------------------+
// |                   |
// |   __  __   __     |
// |  /\ \/\ \ /\ \    |
// |  \ \ \_\ \\ \ \   |
// |   \ \_____\\ \_\  |
// |    \/_____/ \/_/  |
// |                   |
// +-------------------+
// class.UIStyle

enum UIBorderMode {
    Inner,
    Outer,
}
enum UIBorderMask {
	None,
	Top = 1,
	Right = 2,
	Bottom = 4,
	Left = 8,
	All = 1 | 2 | 4 | 8,
}

function UIStyle(_config = {}) : Base(_config) constructor {
    var _self = self;

	#region Config
	
    // Private
	with (__) {
	    box = {
	        content_inset   : _config[$ "content_inset"]   ?? 0,
	        item_spacing    : _config[$ "item_spacing"]    ?? 0,
	        border_mode     : _config[$ "border_mode"]     ?? UIBorderMode.Inner,
			border_mask		: _config[$ "border_mask"]	   ?? UIBorderMask.None,
	        border_sprite   : -1,
	        border_color    : _config[$ "border_color"]    ?? c_white,
	        border_top      : 0,
	        border_bottom   : 0,
	        border_left     : 0,
	        border_right    : 0,
			bg_sprite		: -1,
			bg_color		: c_dkgray,
	    };
	    text = {
	        font            : _config[$ "font"]            ?? -1,
	        color           : _config[$ "text_color"]      ?? c_white,
	        halign          : _config[$ "halign"]          ?? fa_left,
	        valign          : _config[$ "valign"]          ?? fa_top,
	        line_height     : _config[$ "line_height"]     ?? -1,
	        offset_x        : _config[$ "text_offset_x"]   ?? 0,
	        offset_y        : _config[$ "text_offset_y"]   ?? 0,
	    };
		list = {
	        item_spacing    : _config[$ "list_item_spacing" ] ?? box.item_spacing,
	        content_inset   : _config[$ "list_content_inset"] ?? box.content_inset,
	    };
	    scroll_bar = {
	        placement       : _config[$ "scroll_bar_placement"]      ?? undefined,
	        thickness       : _config[$ "scroll_bar_thickness"]      ?? 0,
	        min_thumb_size  : _config[$ "scroll_bar_min_thumb_size"] ?? 0,
	        track_inset     : _config[$ "scroll_bar_track_inset"]    ?? 0,
	    };
		scroll_item = {
			// Set cross axis/main axis default size
		};
	}

    #endregion
    #region Initialize
	
	// Private
	with (__) {
		static __init_border_properties = function(_config = {}) {
			var _default_sprite_name = "spr_ui_border";
	        var _has_border = __.box.border_mask != UIBorderMask.None;
	        var _default_sprite = asset_get_index(_default_sprite_name);
	        __.box.border_sprite = _config[$ "border_sprite"] ?? _default_sprite;
	        if (_has_border && __.box.border_sprite == -1) {
	            show_error("Asset " + _default_sprite_name + " doesn't exist. Create a nine slice sprite to use UI borders.", true);
	        }
	        if (__.box.border_sprite != -1) {
	            var _nine_slice = sprite_get_nineslice(__.box.border_sprite);
	            __.box.border_top    = _nine_slice.top;
	            __.box.border_bottom = _nine_slice.bottom;
	            __.box.border_left   = _nine_slice.left;
	            __.box.border_right  = _nine_slice.right;
	        }
		}
		static __init_bg_properties = function(_config = {}) {
			var _default_sprite_name = "spr_ui_bg";
	        var _default_sprite = asset_get_index(_default_sprite_name);
	        __.box.bg_sprite = _config[$ "bg_sprite"] ?? _default_sprite;
	        if (__.box.bg_sprite == -1) {
	            show_error("Asset " + _default_sprite_name + " doesn't exist. Create a sprite to use UI backgrounds.", true);
	        }
		}
	}
		
	// Events
	on_initialize(function(_config = {}) {
		__init_border_properties(_config);
		__init_bg_properties(_config);
	});
	
    #endregion
    #region Box Getters

    static get_box = function() { return __.box; }

    static get_content_inset = function() { return __.box.content_inset; }
    static get_item_spacing  = function() { return __.box.item_spacing; }

    static get_border_mode   = function() { return __.box.border_mode; }
    static get_border_mask   = function() { return __.box.border_mask; }
    static get_border_sprite = function() { return __.box.border_sprite; }
    static get_border_color  = function() { return __.box.border_color; }

    static get_border_top    = function() { return __.box.border_top; }
    static get_border_bottom = function() { return __.box.border_bottom; }
    static get_border_left   = function() { return __.box.border_left; }
    static get_border_right  = function() { return __.box.border_right; }
	
	static get_bg_sprite	 = function() { return __.box.bg_sprite; }
	static get_bg_color		 = function() { return __.box.bg_color; }

    #endregion
    #region Text Getters

    static get_text = function() { return __.text; }
	
    static get_font        = function() { return __.text.font; }
    static get_text_color  = function() { return __.text.color; }
    static get_halign      = function() { return __.text.halign; }
    static get_valign      = function() { return __.text.valign; }
    static get_line_height = function() { return __.text.line_height; }
    static get_text_offset_x = function() { return __.text.offset_x; }
    static get_text_offset_y = function() { return __.text.offset_y; }

    #endregion
    #region List Getters

    static get_list = function() { return __.list; }
	
    static get_list_item_spacing  = function() { return __.list.item_spacing; }
    static get_list_content_inset = function() { return __.list.content_inset; }

    #endregion
    #region Scrollbar Getters

    static get_scroll_bar = function() { return __.scroll_bar; }
	
    static get_scroll_bar_placement      = function() { return __.scroll_bar.placement; }
    static get_scroll_bar_thickness      = function() { return __.scroll_bar.thickness; }
    static get_scroll_bar_min_thumb_size = function() { return __.scroll_bar.min_thumb_size; }
    static get_scroll_bar_track_inset    = function() { return __.scroll_bar.track_inset; }

    #endregion
    #region Layout Helpers

    static first_item_offset = function() {
        return __.list.content_inset;
    }
    static gap_before = function(_i) {
        return (_i > 0) ? __.list.item_spacing : 0;
    }
    static item_offset = function(_i, _item_size) {
        return __.list.content_inset + _i * (_item_size + __.list.item_spacing);
    }
    static content_size_for = function(_count, _item_size) {
        if (_count <= 0) return __.list.content_inset * 2;

        return __.list.content_inset * 2
            + _count * _item_size
            + max(0, _count - 1) * __.list.item_spacing;
    }
    static content_size_for_sum = function(_count, _total_item_size) {
        if (_count <= 0) return __.list.content_inset * 2;

        return __.list.content_inset * 2
            + _total_item_size
            + max(0, _count - 1) * __.list.item_spacing;
    }
    static available_cross = function(_list_cross) {
        return _list_cross - __.list.content_inset * 2;
    }
	
    #endregion
}