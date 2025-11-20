enum InjuryType {
	Bruise,
	Cut,
	DeepWound,
	Fracture
}

enum InjuryState {
	Minor,
	Moderate,
	Severe
}

enum InjuryAttribute {
	State,			// Minor, moderate, severe
	Severity,		// Used as a threshold % (0, 1) to change injury state, as well as a mult for pain and bleeding rate
	Pain,			// Ranges from 0 to 1
	BleedingRate,	// Ranges from 0 to 1
	Infection,
	Last
}

function Injury(_type, _state, _severity) constructor {
	
	type = _type;
	base = array_create(InjuryAttribute.Last - 1, undefined);
	
	// Set initial attributes
	base[InjuryAttribute.State] = _state;
	base[InjuryAttribute.Severity] = _severity;
	
	// TODO Set initial pain and bleeding rate
	base[InjuryAttribute.Pain] = 0;
	base[InjuryAttribute.BleedingRate] = 0;
	
	#region Methods
	
	/// @description Update injury stat based on the added severity
	update_severity = function(_severity) {
		
		base[InjuryAttribute.Severity] += _severity;
		
		// While severity overflows, promote state
	    while (base[InjuryAttribute.Severity] > 1) {
	        base[InjuryAttribute.Severity] -= 1;
	        base[InjuryAttribute.State]++;

	        // Clamp at Severe
	        if (base[InjuryAttribute.State] > InjuryState.Severe) {
	            base[InjuryAttribute.State] = InjuryState.Severe;
	            base[InjuryAttribute.Severity] = 1;
	            break;
	        }
	    }
	}
	
	/// @description Returns computated pain level
	get_total_pain = function() {
		return 1 * base[InjuryAttribute.Severity] * base[InjuryAttribute.Pain] + (base[InjuryAttribute.State] * 0.1);
	}
	
	/// @description Returns computated bleeding rate
	get_total_bleeding_rate = function() {
		return 1 * base[InjuryAttribute.Severity] * base[InjuryAttribute.BleedingRate] + (base[InjuryAttribute.State] * 0.1);
	}
	
	#endregion
}