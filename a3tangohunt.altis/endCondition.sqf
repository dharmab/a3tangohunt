if (!isServer) exitWith {};
waitUntil {missionNamespace getVariable "mission_tangohunt_init";};

// Wait for at least one enemy to spawn
_enemy_spawned = false;
waitUntil {
	// Check if any enemies are alive
	{
		if (side _x == east and alive _x) then {
			_enemy_spawned = true;
		};
	} forEach allUnits;
	sleep 1;
	_enemy_spawned
};

// Wait for all enemies to die
_victory = false;
waitUntil {
	_victory = true;
	// Check if any enemies are alive
	{
		if (side _x == east and alive _x) then {
			_victory = false;
		};
	} forEach allUnits;

	sleep 15;
	_victory;
};


[["Victory", true, true], "BIS_fnc_endMission", true, false, true] call BIS_fnc_MP;
