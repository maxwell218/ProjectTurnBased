/// @description Create the world, camera and lifeforms
if (room == rm_world) {
	
	// Create camera object
	global.camera = instance_create_layer(x, y, "UI", obj_camera);
	
	// Create world object
	global.world = instance_create_layer(x, y, "Controllers", obj_world);
	
	// Create lifeform controller object
	global.lifeform_controller = instance_create_layer(x, y, "Controllers", obj_lifeform_controller);

	// TODO Create player inventory	
	
	// Trigger game start condition
	event_manager_publish(Event.GameNew);
}