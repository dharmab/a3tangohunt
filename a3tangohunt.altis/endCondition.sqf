if (!isServer) exitWith {};
waitUntil {missionNamespace getVariable "mission_tangohunt_init";};

// Grace period for spawn scripts
sleep 15;

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
		// Check if any enemies are alive
		if (side _x == east) then {
			if (alive _x) then {
				_victory = false;
			};
		};

		// Check if any players are alive and not spectating
		if (side _x == west) then {
			if (alive _x and !([spectate_area, position _x] call BIS_fnc_inTrigger)) then {
				_defeat = false;
			};
		};
	} forEach allUnits;

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