if (!isServer) exitWith {};
waitUntil {missionNamespace getVariable "mission_tangohunt_init";};

// Spawn grace period
sleep 60;

_victory = false;
_defeat = false;
waitUntil {
	_victory = true;
	_defeat = true;
	{
		if (side _x == east) then {
			if (alive _x) then {
				_victory = false;
			};
		};

		if (side _x == west) then {
			if (alive _x and !([spectate_area, position _x] call BIS_fnc_inTrigger)) then {
				_defeat = false;
			};
		};
	} forEach allUnits;

	sleep 5;
	_victory or _defeat;
};

if (_victory) then {
	["Victory", true, true] call BIS_fnc_endMission;
} else {
	["loser", false, true] call BIS_fnc_endMission;
};