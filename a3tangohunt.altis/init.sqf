// Process briefing
execVM "briefing.sqf";

// Wait for server to finish
waitUntil {missionNamespace getVariable "mission_tangohunt_init";};
waitUntil {!isNull player};

// Create task for objective
[player, "task_objective", [
	"Attack the enemy infantry force and secure the area marked on the map.",
	"Secure the area",
	"enemy_area"
], objNull, true] call BIS_fnc_taskCreate;

// Sleep forces further execution to wait until mission has started
sleep 0.1;
[] execVM "loadouts\loadouts.sqf";