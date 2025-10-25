enum FactionType {
	Humans,				// Neutral, default player faction
	WildlifeHostiles,	// Aggressive wildlife
	WildlifeNeutrals,	// Passive wildlife
	Monsters,			// AI controlled monster factions
	Bandits,			// Hostile humans
	Looters,			// Neutral, avoids conflict unless provoked
	Last,
}

function Faction(_name, _type, _color, _compositions) constructor {
	
    name         = _name;
    type         = _type;			// One of FactionType.*
    color        = _color;			// Used for UI
    compositions = _compositions;	// Array of possible group templates

    // Optional: future extensions
    hostility     = {}; // ds_map of relations
    base_location = undefined;
}