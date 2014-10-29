_LISTBOX_IDC = 10002;
_selection = lbText [_LISTBOX_IDC, (lbCurSel _LISTBOX_IDC)];
_faction = ["a3_nato", "a3_fia", "a3_aaf", "a3_csat"] select (["PlayerFaction", 0] call BIS_fnc_getParamValue);
_loadout_script = format ["loadouts\factions\%1.sqf", _faction];
[player, _selection] call compile preprocessFileLineNumbers _loadout_script;
true;