_LISTBOX_IDC = 10002;
_FACTION_TABLE = ["a3_nato", "a3_csat", "a3_aaf", "a3_fia", "rhs_usa", "rhs_rgf"];

// Get the currently selected loadout
_selected_loadout = lbText [_LISTBOX_IDC, (lbCurSel _LISTBOX_IDC)];

// Determine the player faction selected in mission parameters and find the appropriate loadout template
_faction = _FACTION_TABLE select (["PlayerFaction", 0] call BIS_fnc_getParamValue);
_faction_template_script = format ["loadouts\factions\%1.sqf", _faction];
_faction_template = [] call compile preprocessFileLineNumbers _faction_template_script;

// Apply the loadout template
([_selected_loadout] + _faction_template) call TH_fnc_applyLoadout;
true;