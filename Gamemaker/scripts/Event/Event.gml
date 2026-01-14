enum Event {
	
	// Game
	GameNew, // Used to initialize the game's world, camera, lifeforms, etc.
	GameLoad, // Used to determine if we loaded a save
	
	// Turn
	TurnStart, // Used at the start of a new turn
	TurnEnd, // Used when a turn ends
	
	// World
	WorldCreated, // When a new world is created (GameNew)
	WorldLoaded,
	WorldCellSelected,
	
	// Lifeform
	LifeformGroupCreated,
	LifeformGroupDestinationReached,
	
	Last
}