if (isDedicated) exitWith {};

_LOADOUT_SELECTION_DIALOG_IDD = 10001;
_LISTBOX_IDC = 10002;

createDialog "LoadoutSelectionDialog";
lbClear _LISTBOX_IDC;
lbAdd [_LISTBOX_IDC, "Grenadier"];
lbAdd [_LISTBOX_IDC, "Automatic Rifleman"];
lbAdd [_LISTBOX_IDC, "Designated Marksman"];
lbAdd [_LISTBOX_IDC, "Light Anti-Tank"];
lbAdd [_LISTBOX_IDC, "Combat Medic"];

[] call TH_fnc_OnLoadoutSelected;
// `(findDisplay _LOADOUT_SELECTION_DIALOG_IDD) displayCtrl _LISTBOX_IDC` is the loadout selection listbox
// This clunky lookup is required because ui elements do not support serialization
(findDisplay _LOADOUT_SELECTION_DIALOG_IDD) displayCtrl _LISTBOX_IDC ctrlSetEventHandler ["LBSelChanged", "_this call TH_fnc_OnLoadoutSelected"];