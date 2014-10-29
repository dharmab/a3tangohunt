// Process briefing
execVM "briefing.sqf";

// Wait for server to finish
waitUntil {missionNamespace getVariable "mission_tangohunt_init";};
_area_marker = missionNamespace getVariable "mission_area_marker";

waitUntil {!isNull player};

// Create task for objective
[player, "task_objective", [
	"Attack the enemy infantry force and secure the area marked on the map.",
	"Secure the area",
	_area_marker
], objNull, true] call BIS_fnc_taskCreate;

// Sleep forces further execution to wait until mission has started
sleep 0.1;
[] execVM "loadouts\loadouts.sqf";