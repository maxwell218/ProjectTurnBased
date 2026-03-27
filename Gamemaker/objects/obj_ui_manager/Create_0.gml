// +-------------------+
// |                   |
// |   __  __   __     |
// |  /\ \/\ \ /\ \    |
// |  \ \ \_\ \\ \ \   |
// |   \ \_____\\ \_\  |
// |    \/_____/ \/_/  |
// |                   |
// +-------------------+
// obj_ui_manager.create

depth = DepthTable.UI;
var _self = self;

#region Singleton

if (variable_struct_exists(global, "ui_manager") && global.ui_manager != id) {
	show_error("global.ui_manager already exists", true);
}
global.ui_manager = id;
#macro UI_MANAGER global.ui_manager

#endregion
#region Config

// Public
#region Getters

get_active_element = function() {
    return __.active_element;
}
get_ui_format = function() {
	return __.ui_format;
}

#endregion

// Private
__ = {};
with (__) {
	ui_format = new UIFormat({
		content_inset: 0,
		item_spacing: 0,
		border_mode: UIBorderMode.SharedEdge,
	});
    active_scene  = undefined; // single active scene
    modal_stack   = [];        // modals layered on top, last is top-most

    hovered_stack   = [];
    hovered_element = undefined;
    active_element  = undefined;

    action_table = [
        { input: Input.Select, press: InputPressType.Pressed,  func: "on_primary_action_pressed"  },
        { input: Input.Select, press: InputPressType.Released, func: "on_primary_action_released" },
        { input: Input.Select, press: InputPressType.Scroll,   func: "on_scroll"                  },
    ];
}

#endregion
#region Step

// Public
step = function() {
    // Reset previous frame hover state
    clear_hovered_stack();

    // Build hovered stack — modals block scene if any are present
    if (instance_exists(obj_cursor)) {
        get_hovered_stack(round(obj_cursor.gui_x), round(obj_cursor.gui_y));
		var _stack_count = array_length(__.hovered_stack);
        if (_stack_count > 0) {
            __.hovered_element = __.hovered_stack[0];
        }
        for (var _i = 0; _i < _stack_count; _i++) {
            __.hovered_stack[_i].set_is_hovered(true);
        }
    }

    // Step active element or hovered stack
    var _caller = undefined;
    if (__.active_element != undefined) {
        _caller = __.active_element;
        process_action(_caller);
    } else {
        var _stack_count = array_length(__.hovered_stack);
        for (var _i = 0; _i < _stack_count; _i++) {
            var _result = process_action(__.hovered_stack[_i]);
            if (_result) break;
        }
    }

    // Step top-most modal only, or active scene if no modals
    var _modal_count = array_length(__.modal_stack);
    if (_modal_count > 0) {
        __.modal_stack[_modal_count - 1].step();
    } else if (__.active_scene != undefined) {
        __.active_scene.step();
    }
}

#endregion
#region Render

// Public
render = function() {
    // Render active scene first
    if (__.active_scene != undefined) {
        __.active_scene.render();
    }
    // Render modals on top, bottom to top
    var _modal_count = array_length(__.modal_stack);
    for (var _i = 0; _i < _modal_count; _i++) {
        __.modal_stack[_i].render();
    }
}
render_gui = function() {
    if (global.debug) {
        draw_set_halign(fa_left);
        draw_set_valign(fa_bottom);

        var _count  = array_length(__.hovered_stack);
        var _string = "";
        for (var _i = 0; _i < _count; _i++) {
            _string += string(get_struct_name(__.hovered_stack[_i]));
            if (_i < _count - 1) _string += ", ";
        }

        _string = (string_length(_string) > 0) ? _string : "Empty";
        draw_text(0, camera_get_view_height(view_camera[0]) - 32,	"Stack: "  + _string);
        draw_text(0, camera_get_view_height(view_camera[0]) - 24,	"Active: " + string(get_struct_name(__.active_element)));
        draw_text(0, camera_get_view_height(view_camera[0]) - 16,   "Hover: "  + string(get_struct_name(__.hovered_element)));
		if (__.hovered_element != undefined && variable_struct_get(__.hovered_element, "name") == undefined) {
			draw_text(0, camera_get_view_height(view_camera[0]) - 8,	"Pos: "  + string(__.hovered_element.get_x()) + ", " + string(__.hovered_element.get_y()));
			draw_text(0, camera_get_view_height(view_camera[0]),		"Sizes: "  + string(__.hovered_element.get_width()) + ", " + string(__.hovered_element.get_height()));
		}
    }
}

#endregion
#region Stack

// Public
clear_hovered_stack = function() {
    var _stack_count = array_length(__.hovered_stack);
    for (var _i = 0; _i < _stack_count; _i++) {
        __.hovered_stack[_i].set_is_hovered(false);
    }
    __.hovered_stack    = [];
    __.hovered_element  = undefined;
}

get_hovered_stack = function(_mouse_x, _mouse_y) {
    var _modal_count = array_length(__.modal_stack);
    if (_modal_count > 0) {
        // Only top-most modal participates in hover
        __.modal_stack[_modal_count - 1].collect_hover(_mouse_x, _mouse_y, __.hovered_stack);
    } else if (__.active_scene != undefined) {
        __.active_scene.collect_hover(_mouse_x, _mouse_y, __.hovered_stack);
    }
}

#endregion
#region Action

// Public
process_action = function(_caller) {
    if (_caller != undefined) {
        if (variable_struct_exists(_caller, "owner")) {
            _caller = _caller.owner;
        }
        var _action_count = array_length(__.action_table);
        for (var _a = 0; _a < _action_count; _a++) {
            var _action = __.action_table[_a];
            if (_caller[$ _action.func] != undefined && process_input(_action.input, _action.press)) {
                var _caller_func = variable_struct_get(_caller, _action.func);
                var _ref = method(_caller, _caller_func);
                method_call(_ref);
                return true;
            }
        }
    }
    return false;
}

#endregion
#region Helpers

// Public
get_struct_name = function(_struct) {
    var _struct_name;
    if (_struct != undefined) {
        if (variable_struct_exists(_struct, "name")) {
            _struct_name = _struct.name;
        } else {
            _struct_name = instanceof(_struct);
        }
    } else {
        _struct_name = "None";
    }
    return _struct_name;
}

#endregion
#region Events

event_manager_subscribe(Event.ActivateScene, function(_scene) {
    // Deactivate current scene if one is active
    if (__.active_scene != undefined) {
        __.active_scene.deactivate();
    }
    __.active_scene = _scene;
});
event_manager_subscribe(Event.DeactivateScene, function() {
    if (__.active_scene != undefined) {
        __.active_scene.deactivate();
        __.active_scene = undefined;
    }
});
event_manager_subscribe(Event.PushModal, function(_modal) {
    array_push(__.modal_stack, _modal);
});
event_manager_subscribe(Event.PopModal, function() {
    var _modal_count = array_length(__.modal_stack);
    if (_modal_count > 0) {
        array_delete(__.modal_stack, _modal_count - 1, 1);
    }
});
event_manager_subscribe(Event.BringModalToFront, function(_modal) {
    var _modal_count = array_length(__.modal_stack);
    for (var _i = 0; _i < _modal_count; _i++) {
        if (__.modal_stack[_i] == _modal) {
            array_delete(__.modal_stack, _i, 1);
            array_push(__.modal_stack, _modal);
            return;
        }
    }
});
event_manager_subscribe(Event.CaptureActiveElement, function(_element) {
    __.active_element = _element;
});
event_manager_subscribe(Event.UnsetActiveElement, function() {
    __.active_element = undefined;
});

#endregion