/// @description Get movement range

// Update only if we've reached a new tile
if (last_tile != current_tile) {
	update_move_range();
}