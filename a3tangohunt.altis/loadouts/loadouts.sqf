if (isDedicated) exitWith {};

// Player faction from description.ext
_description_ext_player_faction = ["PlayerFaction", 0] call BIS_fnc_getParamValue;
_PLAYER_FACTION_TABLE = ["NATO", "CSAT", "AAF", "FIA", "RHS USA", "RHS AFRF"];
_PLAYER_FACTION = [_PLAYER_FACTION_TABLE, _description_ext_player_faction] call TH_fnc_lookupParameter;

// IDs of UI elements
_LOADOUT_SELECTION_DIALOG_IDD = 10001;
_LISTBOX_IDC = 10002;

_loadouts = [];
if ([getMarkerPos "player_start"] call TH_fnc_isPositionInWater) then {
    _loadouts = ["Diver (Assault)", "Diver (Medic)"];
} else {
    _loadouts = ["Grenadier", "Automatic Rifleman", "Designated Marksman", "Light Anti-Tank", "Combat Medic"];
    if (_PLAYER_FACTION == "NATO" or _PLAYER_FACTION == "CSAT" or _PLAYER_FACTION == "AAF") then {
        _loadouts = _loadouts + ["Scout Sniper"];
    };
};

// Open loadouts UI and add loadout items
createDialog "LoadoutSelectionDialog";
lbClear _LISTBOX_IDC;
{
	lbAdd [_LISTBOX_IDC, _x];
} forEach _loadouts;

// Apply the default loadout
[] call TH_fnc_OnLoadoutSelected;
// When the user clicks on a loadout, apply it
// `(findDisplay _LOADOUT_SELECTION_DIALOG_IDD) displayCtrl _LISTBOX_IDC` is the loadout selection listbox. 
// This clunky one-liner lookup is required because ui elements do not support serialization.
(findDisplay _LOADOUT_SELECTION_DIALOG_IDD) displayCtrl _LISTBOX_IDC ctrlSetEventHandler ["LBSelChanged", "_this call TH_fnc_OnLoadoutSelected"];