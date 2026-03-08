// +--------------------------------------+
// |                                      |
// |   __   ______  ______   __    __     |
// |  /\ \ /\__  _\/\  ___\ /\ "-./  \    |
// |  \ \ \\/_/\ \/\ \  __\ \ \ \-./\ \   |
// |   \ \_\  \ \_\ \ \_____\\ \_\ \ \_\  |
// |    \/_/   \/_/  \/_____/ \/_/  \/_/  |
// |                                      |
// +--------------------------------------+
// interface.global_item_data

function IGlobalItemData(_config = {}) constructor {
	uid  = _config[$ "uid" ] ?? undefined;
	name = _config[$ "name"] ?? "";
	desc = _config[$ "desc"] ?? "...";
	
	category = _config[$ "category"] ?? ItemCategory.Material;
	weigth   = _config[$ "weigth"  ] ?? 0;
}

// Required item data
function IGlobalItemData_Sprite(_config = {}) constructor {
	
}
function IGlobalItemData_Shape(_config = {}) constructor {}

// Optional item data
function IGlobalItemData_Container(_config = {}) constructor {}
function IGlobalItemData_EquipmentSlot(_config = {}) constructor {}
function IGlobalItemData_Ammo(_config = {}) constructor {}