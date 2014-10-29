_LISTBOX_IDC = 10002;

// `(findDisplay _LOADOUT_SELECTION_DIALOG_IDD) displayCtrl _LISTBOX_IDC` is the loadout selection listbox
// This clunky lookup is required because ui elements do not support serialization
_selection = lbText [_LISTBOX_IDC, (lbCurSel _LISTBOX_IDC)];

_loadout = "";
switch (_selection) do {
    case "Grenadier":
    {
        _loadout = "grenadier";
    };
    case "Automatic Rifleman":
    {
        _loadout = "automatic_rifleman";
    };
    case "Designated Marksman":
    {
        _loadout = "designated_marksman";
    };
    case "Light Anti-Tank":
    {
        _loadout = "light_anti_tank";
    };
    case "Combat Medic":
    {
        _loadout = "medic";
    };
    default
    {
        _loadout = "grenadier";
    };
};

_faction = ["a3_nato", "a3_fia", "a3_aaf", "a3_csat"] select (["PlayerFaction", 0] call BIS_fnc_getParamValue);
_loadout_script = format ["loadouts\%1\%2.sqf", _faction, _loadout];
[player] call compile preprocessFileLineNumbers _loadout_script;

true;