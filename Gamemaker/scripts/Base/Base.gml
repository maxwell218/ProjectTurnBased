// +-----------------------------------------+
// |                                         |
// |   ______   ______   ______   ______     |
// |  /\  == \ /\  __ \ /\  ___\ /\  ___\    |
// |  \ \  __< \ \  __ \\ \___  \\ \  __\    |
// |   \ \_____\\ \_\ \_\\/\_____\\ \_____\  |
// |    \/_____/ \/_/\/_/ \/_____/ \/_____/  |
// |                                         |
// +-----------------------------------------+
// class.Base

function Base(_config = {}) constructor {
	var _self = self;
	
	#region Config
	
	// Private
	__ = {};
	
	#endregion
	#region Initialize
	
	// Public
	static initialize = function() {
		for (var _i = 0, _len = array_length(__.on_initialize_callbacks); _i < _len; _i++) {
			var _on_initialize_insert = __.on_initialize_callbacks[_i];
			var _callback			  = _on_initialize_insert.callback;
			var _data				  = _on_initialize_insert.data;
			_callback(_data);
		}
	}
	static on_initialize = function(_callback, _data = undefined) {
		array_push(__.on_initialize_callbacks, {
			callback: _callback,
			data:	  _data,
		});
		return self;
	}
	
	// Private
	with (__) {
		on_initialize_callbacks = [];
	}
	
	// Events
	on_initialize(function() {});
	
	#endregion
	#region Update
	
	// Public
	static update = function() {
		for (var _i = 0, _len = array_length(__.on_update_callbacks); _i < _len; _i++) {
			var _on_update_insert = __.on_update_callbacks[_i];
			var _callback		  = _on_update_insert.callback;
			var _data			  = _on_update_insert.data;
			_callback(_data);
		}
	}
	static on_update = function(_callback, _data = undefined) {
		array_push(__.on_update_callbacks, {
			callback: _callback,
			data:	  _data,
		});
		return self;
	}
	
	// Private
	with (__) {
		on_update_callbacks = [];
	}
	
	// Events
	on_update(function() {});
	
	#endregion
	#region Render
	
	// Public
	static render = function() {
		for (var _i = 0, _len = array_length(__.on_render_callbacks); _i < _len; _i++) {
			var _on_render_insert = __.on_render_callbacks[_i];
			var _callback		   = _on_render_insert.callback;
			var _data			   = _on_render_insert.data;
			_callback(_data);
		}
	}
	static on_render = function(_callback, _data = undefined) {
		array_push(__.on_render_callbacks, {
			callback: _callback,
			data:	  _data,
		});
		return self;
	}
	
	// Private
	with (__) {
		on_render_callbacks = [];
	}
	
	// Events
	on_render(function() {});
	
	#endregion
	#region Cleanup
	
	// Public
	static cleanup = function() {
		for (var _i = 0, _len = array_length(__.on_cleanup_callbacks); _i < _len; _i++) {
			var _on_cleanup_insert = __.on_cleanup_callbacks[_i];
			var _callback		   = _on_cleanup_insert.callback;
			var _data			   = _on_cleanup_insert.data;
			_callback(_data);
		}
	}
	static on_cleanup = function(_callback, _data = undefined) {
		array_push(__.on_cleanup_callbacks, {
			callback: _callback,
			data:	  _data,
		});
		return self;
	}
	
	// Private
	with (__) {
		on_cleanup_callbacks = [];
	}
	
	// Events
	on_cleanup(function() {});
	
	#endregion
}