/*
Main control for game over logic

This script only takes action in multiplayer. In singleplayer, it exits 
immediately and allows the game's standard game over logic to handle
player death.

This script idles until at least one BLUFOR and at least one OPFOR have spawned.
Once that condition is met, the scripts waits until either all BLUFOR are dead
or all OPFOR are dead.

If all OPFOR are dead, the victory screen is displayed and the mission ends.

If all BLUFOR are dead, the defeat screen is displayed and the mission ends.
*/
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

			if (!isMultiplayer || side (group _x) == west) then {
				_defeat = false;
			};
		};

		if (!_victory and !_defeat) exitWith {};
	} forEach allUnits + allDeadMen;

	sleep 5;
	_victory or _defeat;
};

_args = [];
if (_victory) then {
	_args = ["Victory", true, true]
} else {
	_args = ["loser", false, true]
};

[_args, "BIS_fnc_endMission", true, false, true] call BIS_fnc_MP;