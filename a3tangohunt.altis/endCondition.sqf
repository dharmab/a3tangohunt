if (!isServer) exitWith {};
waitUntil {missionNamespace getVariable "mission_tangohunt_init";};

// Wait for at least one player to spawn
_player_spawned = false;
waitUntil {
	{
		if (alive _x) then {
			_player_spawned = true;
		}
	} forEach playableUnits;
	sleep 1;
	_player_spawned;
};

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

if (_victory) then {
	["Victory", true, true] call BIS_fnc_endMission;
} else {
	["loser", false, true] call BIS_fnc_endMission;
};