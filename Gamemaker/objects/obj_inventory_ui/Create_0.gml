#region Methods

get_container_under_cursor = function() {
	
}

add_item_to_container = function(_item, _container) {
	
}

draw_container = function(_x, _y, _container) {
	
	var _col = _container.width;
	var _row = _container.height;
	for (var _i = 0; _i < _col; _i++) {
		var _x_offset = _x + _i * 12;
		for (var _j = 0; _j < _row; _j++) {
			var _y_offset = _y + _j * 12;
			draw_sprite(spr_grid_cell, 0, _x + _x_offset, _y + _y_offset);
		}
	}
}

#endregion

// 1. Create hardcoded items
backpack = item("item_backpack", "Backpack", spr_shapes);
backpack.components.equipment_component = equipment_component(HumanEquipmentSlot.Back, undefined);
backpack.components.container_component = container_component(3, 2, undefined);

gas_mask = item("item_gas_mask", "Gas mask", spr_shapes);
gas_mask.components.equipment_component = equipment_component(HumanEquipmentSlot.Face, [HumanEquipmentSlot.Eye]);

knife = item("item_knife", "Knife", spr_shapes);

// 2. Create hardcoded containers
// 2.1 Create ground container
ground_container = container_component(10, 10, undefined);

// 2.2 Create one lifeform inventory, equipment slots and any special containers (hands)
lifeform_container = container_component(10, 10, undefined);

// 3. Refactor lifeform modifiers to support equipment
// 4. Container logic
// 5. Equip logic
// 5.1 Weapon logic
// 5.2 Backpack logic
// 6. Unequip logic

// Create small world sample with seperate containers