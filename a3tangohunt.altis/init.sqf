waitUntil {!isNil "BIS_fnc_init"};
if (!isMultiplayer) then {
	["SinglePlayer", false, 0] spawn BIS_fnc_endMission;
} else {
	execVM "briefing.sqf";

	// Add loadouts from description.ext
	[west, "NatoGrenadier"] call BIS_fnc_addRespawnInventory;
	[west, "NatoAutomaticRifleman"] call BIS_fnc_addRespawnInventory;
	[west, "NatoDesignatedMarksman"] call BIS_fnc_addRespawnInventory;

	// Do not allow any additional respawns
	if (isServer) then {
		[missionNamespace, 1] call BIS_fnc_respawnTickets;
	};

	// Run the setup script
	execVM "setup.sqf";
}