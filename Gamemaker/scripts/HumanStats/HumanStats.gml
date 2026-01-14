enum HumanBodyPart {
    Head,
    UpperBody,
    LowerBody,
    LeftUpperArm,
    LeftLowerArm,
    RightUpperArm,
    RightLowerArm,
    LeftUpperLeg,
    LeftLowerLeg,
    RightUpperLeg,
    RightLowerLeg,
	Last
}

function HumanStats() constructor {
	
	base = [];
	
	// TODO Initialize other base lifeform stats
	base[LifeformStat.CurrentHealth] = 100;
	base[LifeformStat.MaxHealth] = 100;
	base[LifeformStat.MovePoints] = 5;
	
	// 2D array of injuries for each body parts
	body_part_injuries = array_create(HumanBodyPart.Last, []);
	
	// Array of structs {source, target, value}
    modifiers = [];

    #region Methods
	
	// Edge cases:
	// If we have a severe cut with max severity, we need the health system to transform the injury from cut to deep wound
	// If we have severe bruising with max severity, we need to create a new fracture injury to the same body part, while keeping all other active injuries
	add_injury = function(_body_part, _injury) {
		
	}

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

    get_final_stat = function(_name) {
		
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