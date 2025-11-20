change_to_next_list = function(_inputs) {
	show_debug_message("Test");
}

depth = DepthTable.UI;

list1 = array_create(20);
list2 = array_create(3);

injuries_list = new ScrollListView(100, 25, 136, 200, []);
injuries_list.init();

context = new InputContext(self, ContextPriority.UI, true);
context.add_action_group([Input.Left, Input.Right], change_to_next_list, 0, true);

event_manager_publish(Event.AddContext, context);