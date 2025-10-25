#macro PLAYER_GROUP_ID 0

function LifeformGroup(_members, _leader, _faction, _id = undefined) constructor {
	
    // Static variables
    static next_id = 1;
    static free_ids = []; // reusable IDs

    // Assign ID
	if (_id != undefined) {
		group_id = _id;
	} else {
	    if (array_length(free_ids) > 0) {
	        group_id = free_ids[0]; // take first free ID
	        array_delete(free_ids, 0, 1);
	    } else {
	        group_id = next_id;
	        next_id += 1;
	    }
	}

    // Assign other properties
    members = _members;
    leader  = _leader;
    faction = _faction;
	
	// Reference of the cell on which the lifeform is currently on
	current_tile = undefined;
	last_tile = undefined;
	
	#region Methods
	
	init = function(_world_cell) {
		current_tile = _world_cell;
		last_tile = current_tile;
	}

    // Destroy method to recycle ID
    destroy = function() {
        array_push(free_ids, group_id); // Recycle ID
        members = [];
        leader  = undefined;
        faction = undefined;
    }
	
	#endregion
}