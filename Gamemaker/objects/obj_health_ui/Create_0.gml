/*
#region Methods

change_to_next_list = function(_states) {
	
	var _dx = _states[$ Input.Right].pressed - _states[$ Input.Left].pressed;
	var _new_list = current_list + _dx;
	
	if (_new_list > array_length(lists) - 1) {
		_new_list = 0;
	} else if (_new_list < 0) {
		_new_list = array_length(lists) - 1;
	}
	
	current_list = _new_list;
	injuries_list.update_children(lists[current_list]);
}

button_clicked = function () {
	show_debug_message("Clicked " + string(delta_time));
}

#endregion

#region Variables

list1 = array_create(20);
list2 = array_create(32);

injuries_list = new ScrollListView(10, 24, 110, 200, list1);
injuries_list.init();

injuries_list2 = new ScrollListView(200, 24, 110, 200, list2);
injuries_list2.init();

button = new Button(10, 4, 16, 16, button_clicked);

health_ui_panel = new Panel(0, 0, 400, 230, [injuries_list, injuries_list2, button]);

#endregion

#region Events

event_manager_publish(Event.AddUIRoot, health_ui_panel);

#endregion
 */

depth = DepthTable.UI;

//stat = new StatusBar({
//	x: 12,
//	y: 48,
//	width: 71,
//	height: 5,
//});

stat_value = 0;

list1 = array_create(20);

//list = new ScrollList({
//	x: 0,
//	y: 0,
//	width: 480,
//	height: 42,
//	padding: 0,
//	content_height: 36,
//	scroll_axis: ScrollAxis.Horizontal,
//	children: list1,
//});

list = new ScrollList({
	x: 0,
	y: 0,
	width: 200,
	height: 200,
	padding: 5,
	scroll_axis: ScrollAxis.Vertical,
	size_mode: ScrollListSizeMode.PushLayout,
	children: list1,
});

list.init();

health_ui_panel = new Panel({
	x: 0,
	y: 0,
	width: 480,
	height: 200,
	children: [list],
});

#region Events

event_manager_publish(Event.AddUIRoot, health_ui_panel);

#endregion