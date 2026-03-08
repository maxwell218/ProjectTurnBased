// +--------------------------------------+
// |                                      |
// |   __   ______  ______   __    __     |
// |  /\ \ /\__  _\/\  ___\ /\ "-./  \    |
// |  \ \ \\/_/\ \/\ \  __\ \ \ \-./\ \   |
// |   \ \_\  \ \_\ \ \_____\\ \_\ \ \_\  |
// |    \/_/   \/_/  \/_____/ \/_/  \/_/  |
// |                                      |
// +--------------------------------------+
// global.item_database

enum ItemCategory {
	Medicine,
	Weapon,
	Equipment,
	Consumable,
	Material,
}

global.item_database = {};
with (global.item_database) {
	self[$ "item_shotgun"] = new IGlobalItemData({
		uid: "item_shotgun",
		name: "Shotgun",
		desc: "A pump-action shotgun",
		category: ItemCategory.Weapon,
		weigth: 6.0,
		condition: 100,
		sprite: {
			item: undefined,
			world: undefined,
		},
		shape: {},
	});
}

#macro ITEM_DATA global.item_database