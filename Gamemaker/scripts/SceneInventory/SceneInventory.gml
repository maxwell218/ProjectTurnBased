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
        var _list = array_create(1);

        // --- Elements ---
        __.elements.unit_list        = new ScrollList({
			width:		 VIEW_MANAGER.__.base_width,
            height:      36,
            children:    _list,
            scroll_axis: ScrollAxis.Horizontal,
            size_mode:   ScrollListSizeMode.ScrollbarExcluded,
        });
        __.elements.equipment_left   = new UIPlaceholder({});
        __.elements.containers_left  = new UIPlaceholder({});
        __.elements.equipment_right  = new UIPlaceholder({});
        __.elements.containers_right = new UIPlaceholder({});
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
                measure: function(_element) {
                    return {
                        width:  _element.get_width(),
                        height: _element.get_height(),
                    };
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

        __.layout.solve();
    }
	
    #endregion
}