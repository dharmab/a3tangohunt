if (!isMultiplayer) then {
	["SinglePlayer", false, 0] spawn BIS_fnc_endMission;
} else {
	execVM "briefing.sqf";

	// Add loadouts from description.ext
	[west, "NatoGrenadier"] call BIS_fnc_addRespawnInventory;
	[west, "NatoAutomaticRifleman"] call BIS_fnc_addRespawnInventory;
	[west, "NatoDesignatedMarksman"] call BIS_fnc_addRespawnInventory;
	[west, "NatoAntiarmor"] call BIS_fnc_addRespawnInventory;
	[west, "NatoMedic"] call BIS_fnc_addRespawnInventory;
	[west, "NatoRecon"] call BIS_fnc_addRespawnInventory;
	[west, "NatoExplosive"] call BIS_fnc_addRespawnInventory;

	// Run the setup script
	execVM "setup.sqf";
}