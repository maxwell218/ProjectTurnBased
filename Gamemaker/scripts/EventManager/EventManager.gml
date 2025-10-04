enum EventData {
	InstId = 0,
	InstFunc = 1,
}

function EventManager() constructor {
	
	events = {};
	
	// Struct keys/variables are the event name
	// The data attached to these keys will be a 2D array of arrays 
	// Each array within the array key has an id of the object who subscribed to that event
	// as well as a function for that object to do once that event is fired
	/*
	events = {
		"event name" = [
			[id, func],
			... ,
			[id, func]
		],
		... ,
		"event name" = [
			[id, func],
			... ,
			[id, func]
		]
	}
	*/
	
	subscribe = function(_id, _event, _func) {
	    if (is_undefined(events[$ _event])) {
			events[$ _event] = [];
	    } else if (is_subscribed(_id, _event) != -1) {
			return;
	    } 
		array_push(events[$ _event], [_id, _func]);
	}

	publish = function(_event, _data) {
		var _subscriber_array = events[$ _event];
		
		// If the event doesn't exist, we simply exit
	    if (is_undefined(_subscriber_array)) {
			return;
	    }
		
		// Trigger all subscribers
		for (var _i = array_length(_subscriber_array) - 1; _i >= 0; _i--) {
			// If the subscriber is a struct or an existing instance, we fire its function with the publisher's data
			if (instance_exists(_subscriber_array[_i][EventData.InstId]) || is_struct(_subscriber_array[_i][EventData.InstId])) {
				_subscriber_array[_i][EventData.InstFunc](_data);
			} 
			// If the instance/struct doesn't exist, remove the entry
			else {
				array_delete(_subscriber_array, _i, 1);
			}
		}
	
	}

	is_subscribed = function(_id, _event) {
	    for (var _i = 0; _i < array_length(events[$ _event]); _i++) {
	        if (events[$ _event][_i][EventData.InstId] == _id) {
	            return _i;
	        }
	    }  
	    return -1;
	}

	unsubscribe = function(_id, _event) {
	    if (is_undefined(events[$ _event])) return;
	  
	    var _pos = is_subscribed(_id, _event);
	    if (_pos != -1) {
			array_delete(events[$ _event], _pos, 1);
	    }
    
	}

	unsubscribe_all = function(_id) {
		// Get all the event names
		var _keys_array = variable_struct_get_names(events);
		
		for (var _i = array_length(_keys_array) - 1; _i >= 0; _i--) {
			unsubscribe(_id, _keys_array[_i]);
		}
	}

	remove_event = function(_event) {
	    if (variable_struct_exists(events, _event)) {
			variable_struct_remove(events, _event);
	    }
	}

	remove_all_events = function() {
		delete events;
		events = {};
	}

	remove_dead_instances = function() {
		var _keys_array = variable_struct_get_names(events);
		for (var _i = 0; _i < array_length(_keys_array); _i++) {
			var _keys_array_subs = events[$ _keys_array[_i]];
			for (var _j = array_length(_keys_array_subs) - 1; _j >= 0; _j--) {
				// If the subscriber is an object
				if (!instance_exists(_keys_array_subs[_j][0])) {
					array_delete(events[$ _keys_array[_i]], _j, 1);
				}
			}
		}
	}
	
}

// Global Functions
function event_manager_subscribe(_event, _func) {
	with (global.event_manager) {
		// var _id = undefined;
		var _sub = (is_struct(other)) ? other : other.id;
		subscribe(_sub, _event, _func);
		return true;
	}
	return false;
}

function event_manager_unsubscribe(_event) {
	with (global.event_manager) {
		var _sub = (is_struct(other)) ? other : other.id;
		unsubscribe(_sub, _event);
		return true;
	}
	return false;
}

function event_manager_unsubscribe_all() {
	with (global.event_manager) {
		var _sub = (is_struct(other)) ? other : other.id;
		unsubscribe_all(_sub);
		return true;
	}
	return false;
}

function event_manager_publish(_event, _data = undefined) {
	with (global.event_manager) {
	    publish(_event, _data);
	    return true;
	}
	return false;
}