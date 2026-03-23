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

    // Public
    static build = function() {
		var _list = array_create(20);
        // --- Elements ---
        __.elements.unit_list = new ScrollList({
			height: 42,
			children: _list,
            scroll_axis: ScrollAxis.Horizontal,
            size_mode:   ScrollListSizeMode.ShrinkContent,
        });
        // __.elements.unit_list			= new UIPlaceholder({width: 0, height: 42});  // TODO replace with real element
        __.elements.equipment_left		= new UIPlaceholder({});  // TODO replace with real element
        __.elements.containers_left		= new UIPlaceholder({});  // TODO replace with real element
        __.elements.equipment_right		= new UIPlaceholder({});  // TODO replace with real element
        __.elements.containers_right	= new UIPlaceholder({});  // TODO replace with real element
        __.elements.navbar				= new UIPlaceholder({});  // TODO replace with real element

        // --- Inner row layout ---
        var _row = new Layout({ axis: LayoutAxis.Row });
        _row
			.add_node({
                element: __.elements.equipment_left,
                width:   new LayoutSizeFixed({px: 73}),
                height:  new LayoutSizeFill(),
            })
            .add_node({
                element: __.elements.containers_left,
                width:   new LayoutSizeFill(),
                height:  new LayoutSizeFill(),
            })
            .add_node({
                element: __.elements.equipment_right,
                width:   new LayoutSizeFixed({px: 73}),
                height:  new LayoutSizeFill(),
            })
            .add_node({
                element: __.elements.containers_right,
                width:   new LayoutSizeFill(),
                height:  new LayoutSizeFill(),
            });

        // --- Root layout ---
        __.layout = new Layout({
            axis:   LayoutAxis.Column,
            x:      0,
            y:      0,
            width:  display_get_gui_width(),
            height: display_get_gui_height(),
        });
        __.layout
			.add_node({
                element: __.elements.unit_list,
                width:   new LayoutSizeFill(),
                height:  new LayoutSizeHug(),
            })
            .add_node({
                element: _row,
                width:   new LayoutSizeFill(),
                height:  new LayoutSizeFill(),
            })
            .add_node({
                element: __.elements.navbar,
                width:   new LayoutSizeFill(),
                height:  new LayoutSizeFixed({px: 32}),
            });
			
		// Init elements that need it
        __.elements.unit_list.init();
    }

    #endregion
}