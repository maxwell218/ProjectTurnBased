function Lifeform(_lifeform_type, _world_cell) constructor {
	
	switch(_lifeform_type) {
		default:
			var _x = _world_cell.x + HEX_WIDTH div 2;
			var _y = _world_cell.y + HEX_HEIGHT div 2;
			
			var _lifeform_inst = instance_create_layer(_x, _y, "Lifeforms", obj_human);
			break;
	}
}