_LISTBOX_IDC = 10002;
_FACTION_TABLE = ["a3_nato", "a3_csat", "a3_aaf", "a3_fia", "rhs_usa", "rhs_rgf"];

// Get the currently selected loadout
_selection = lbText [_LISTBOX_IDC, (lbCurSel _LISTBOX_IDC)];

// Determine the player faction selected in mission parameters and find the appropriate loadout template
_faction = _FACTION_TABLE select (["PlayerFaction", 0] call BIS_fnc_getParamValue);
_loadout_script = format ["loadouts\factions\%1.sqf", _faction];

// Apply the loadout template
[player, _selection] call compile preprocessFileLineNumbers _loadout_script;
true;