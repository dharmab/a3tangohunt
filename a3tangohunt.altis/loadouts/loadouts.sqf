if (isDedicated) exitWith {};
_LISTBOX_IDC = 10002;
_OK_BUTTON_IDC = 10003;

_dialog = createDialog "LoadoutSelectionDialog";

lbClear _LISTBOX_IDC;
lbAdd [_LISTBOX_IDC, "Grenadier"];
lbAdd [_LISTBOX_IDC, "Automatic Rifleman"];
lbAdd [_LISTBOX_IDC, "Designated Marksman"];
lbAdd [_LISTBOX_IDC, "Antiarmor Specialist"];
lbAdd [_LISTBOX_IDC, "Combat Medic"];
