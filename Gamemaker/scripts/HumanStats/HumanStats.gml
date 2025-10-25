
function HumanStats() constructor {
	
	base = [];
	
	base[LifeformStat.MovePoints] = 5;
	
	// Array of structs {source, target, value}
    modifiers = [];

    #region Methods

    add_modifier = function(_source, _target, _value) {
        var _mod = { source: _source, target: _target, value: _value };
        array_push(modifiers, _mod);
    }

    remove_modifier = function(_source) {
        for (var _i = array_length(modifiers) - 1; _i >= 0; _i--) {
            if (modifiers[_i].source == _source) {
                array_delete(modifiers, _i, 1);
            }
        }
    }

    get_stat = function(_name) {
        var _value = base[_name];
        if (is_undefined(_value)) return 0;
        for (var _i = 0; _i < array_length(modifiers); _i++) {
            var _mod = modifiers[_i];
            if (_mod.target == _name) _value += _mod.value;
        }
        return _value;
    }
	
	#endregion
}