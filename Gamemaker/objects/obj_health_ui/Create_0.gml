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

depth = DepthTable.UI;

list1 = array_create(20);
list2 = array_create(3);
list3 = array_create(52);

lists = [list1, list2, list3];
current_list = 0;

injuries_list = new ScrollListView(100, 25, 130, 200, list1);
injuries_list.init();

button = new Button(0, 0, 16, 16, button_clicked);

#endregion