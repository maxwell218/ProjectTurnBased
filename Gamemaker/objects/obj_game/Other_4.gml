/// @description Create the world
if (room == rm_world) {
	
	// Create camera object
	camera = instance_create_layer(x, y, "UI", obj_camera);
	
	// Create world object
	world = instance_create_layer(0, 0, "Controllers", obj_world);
	

	// TODO Create player inventory	
}