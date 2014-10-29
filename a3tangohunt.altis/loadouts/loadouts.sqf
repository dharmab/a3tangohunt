if (isDedicated) exitWith {};

// IDs of UI elements
_LOADOUT_SELECTION_DIALOG_IDD = 10001;
_LISTBOX_IDC = 10002;

// Use Diver loadouts if player is in water
_loadouts = if ([getPos player] call TH_fnc_isPositionInWater) then {
    ["Diver (Assault)", "Diver (Medic)"];
} else {
    ["Grenadier", "Automatic Rifleman", "Designated Marksman", "Light Anti-Tank", "Combat Medic"];
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