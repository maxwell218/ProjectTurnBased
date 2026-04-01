scroll_container = new ScrollContainer({
	x: 0,
	y: 0,
	width: 100,
	height: 50,
});

// TODO Let ui_manager initialize scenes
scroll_container.initialize();

event_manager_publish(Event.ActivateScene, scroll_container);