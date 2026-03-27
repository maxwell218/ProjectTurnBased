// +---------------------------------------------------+
// |                                                   |
// |   ______   ______   ______   __   __   ______     |
// |  /\  ___\ /\  ___\ /\  ___\ /\ "-.\ \ /\  ___\    |
// |  \ \___  \\ \ \____\ \  __\ \ \ \-.  \\ \  __\    |
// |   \/\_____\\ \_____\\ \_____\\ \_\\"\_\\ \_____\  |
// |    \/_____/ \/_____/ \/_____/ \/_/ \/_/ \/_____/  |
// |                                                   |
// +---------------------------------------------------+
// class.SceneInventory

function SceneInventory(_config) : Scene(_config) constructor {
    var _self = self;

    #region Build
	
    static build = function() {
		// TODO Inject actual data
        var _list = array_create(10);
		var _list_2 = array_create(5);
		var _list_3 = array_create(2);

        // --- Elements ---
        __.elements.unit_list = new ScrollList({
            height:      36,
            children:    _list,
			ui_format: new UIFormat({
				content_inset: 0,
				item_spacing: -1,
				border_mode: UIBorderMode.SharedEdge,
			}),
            scroll_axis: ScrollAxis.Horizontal,
            size_mode:   ScrollListSizeMode.ScrollbarExcluded,
        });
        __.elements.equipment_left   = new UIPlaceholder({});
        __.elements.containers_left  = new ScrollList({
			children: _list_2,
			ui_format: new UIFormat({
				content_inset: 11,
				item_spacing: 11,
				border_mode: UIBorderMode.SharedEdge,
			}),
			scroll_axis: ScrollAxis.Vertical,
            size_mode:   ScrollListSizeMode.ScrollbarIncluded,
		});
        __.elements.equipment_right  = new UIPlaceholder({});
        __.elements.containers_right = new ScrollList({
			children: _list_3,
			ui_format: new UIFormat({
				content_inset: 11,
				item_spacing: 11,
				border_mode: UIBorderMode.SharedEdge,
			}),
			scroll_axis: ScrollAxis.Vertical,
            size_mode:   ScrollListSizeMode.ScrollbarIncluded,
		});
        __.elements.navbar           = new UIPlaceholder({});

        // --- Inner row ---
        var _row = new LayoutContainer({ direction: LayoutDirection.Horizontal });
        _row
        .add_node(new LayoutNode({
                element: __.elements.equipment_left,
                size_x:  new LayoutFixed({ pixels: 73 }),
                size_y:  new LayoutFill(),
            }))
        .add_node(new LayoutNode({
                element: __.elements.containers_left,
                size_x:  new LayoutFill(),
                size_y:  new LayoutFill(),
            }))
        .add_node(new LayoutNode({
                element: __.elements.equipment_right,
                size_x:  new LayoutFixed({ pixels: 73 }),
                size_y:  new LayoutFill(),
            }))
        .add_node(new LayoutNode({
                element: __.elements.containers_right,
                size_x:  new LayoutFill(),
                size_y:  new LayoutFill(),
            }));

        // --- Root layout ---
        __.layout = new LayoutContainer({
            direction: LayoutDirection.Vertical,
            x:         0,
            y:         0,
            width:     display_get_gui_width(),
            height:    display_get_gui_height(),
        });
        __.layout
        .add_node(new LayoutNode({
                element: __.elements.unit_list,
                size_x:  new LayoutFill(),
                size_y:  new LayoutContent(),
                measure: function(_element, _available_w, _available_h) {
				    return _element.measure_size(_available_w, _available_h);
				},
            }))
        .add_node(new LayoutNode({
                element: _row,
                size_x:  new LayoutFill(),
                size_y:  new LayoutFill(),
            }))
        .add_node(new LayoutNode({
                element: __.elements.navbar,
                size_x:  new LayoutFill(),
                size_y:  new LayoutFixed({ pixels: 32 }),
            }));
			
		__.elements.unit_list.init();
		__.elements.containers_left.init();
		__.elements.containers_right.init();
        __.layout.solve();
    }
	
    #endregion
}