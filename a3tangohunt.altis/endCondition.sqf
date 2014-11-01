if (!isServer) exitWith {};
waitUntil {missionNamespace getVariable "mission_tangohunt_init";};

// Wait for at least one player and one enemy to spawn
_player_spawned = false;
_enemy_spawned = false;
waitUntil {
	{
		// Check if any enemies are alive
		if (side _x == east) then {
			if (alive _x) then {
				_enemy_spawned = true;
			};
		};

		// Check if any players are alive
		if (side _x == west) then {
			if (alive _x ) then {
				_player_spawned = true;
			};
		};

		if (_enemy_spawned and _player_spawned) exitWith {};
	} forEach allUnits;

	sleep 1;
	_player_spawned and _enemy_spawned
};

// Wait for either all players or all enemies to die
_victory = false;
_defeat = false;
waitUntil {
	_victory = true;
	_defeat = true;
	{
		if (alive _x) then {
			if (side (group _x) == east) then {
				_victory = false;
			};

			if (side (group _x) == west) then {
				_defeat = false;
			};
		};

		if (!_victory and !_defeat) exitWith {};
	} forEach allUnits + allDeadMen;

	sleep 15;
	_victory or _defeat;
};

_args = [];
if (_victory) then {
	_args = ["Victory", true, true]
} else {
	_args = ["loser", false, true]
};

[_args, "BIS_fnc_endMission", true, false, true] call BIS_fnc_MP;