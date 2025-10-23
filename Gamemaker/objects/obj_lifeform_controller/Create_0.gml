/// @description Define turn order

enum TurnOrder {
	Player,
	Ai,
	Last,
}

current_turn = TurnOrder.Player;

#region Methods

get_current_turn = function() {
	return current_turn;
}

#endregion