_LISTBOX_IDC = 10002;

// Get the currently selected loadout
_loadout = lbText [_LISTBOX_IDC, (lbCurSel _LISTBOX_IDC)];

_faction_template = [[] call TH_fnc_getPlayerFaction] call TH_fnc_getFactionTemplate;

_uniform              = "";
_vest                 = "";
_vest_gl              = "";
_backpack             = "";
_headgear             = "";
_goggles              = "";
_rifle                = "";
_rifle_gl             = "";
_rifle_carbine        = "";
_rifle_dmr            = "";
_automatic_rifle      = "";
_sniper_rifle         = "";
_pistol               = "";
_light_at             = "";
_rifle_ammo           = "";
_rifle_dmr_ammo       = "";
_automatic_rifle_ammo = "";
_sniper_rifle_ammo    = "";
_pistol_ammo          = "";
_light_at_ammo        = "";
_rifle_optic          = "";
_rifle_dmr_optic      = "";
_sniper_rifle_optic   = "";
_rifle_accessory      = "";
_frag_grenade         = "";
_smoke_grenade        = "";
_chemlight            = "";
_ir_grenade           = "";
_gl_he                = "";
_gl_flare_red         = "";
_gl_flare_green       = "";
_gl_smoke_red         = "";
_gl_smoke_green       = "";

// Load template
{
	_key = _x select 0;
	_value = _x select 1;

	switch (_key) do {
		case "uniform": {
			_uniform = _value;
		};
		case "vest": {
			_vest = _value;
		};
		case "vest_gl": {
			_vest_gl = _value;
		};
		case "backpack": {
			_backpack = _value;
		};
		case "headgear": {
			_headgear = _value;
		};
		case "goggles": {
			_goggles = _value;
		};
		case "rifle": {
			_rifle = _value;
		};
		case "rifle_gl": {
			_rifle_gl = _value;
		};
		case "rifle_carbine": {
			_rifle_carbine = _value;
		};
		case "rifle_dmr": {
			_rifle_dmr = _value;
		};
		case "automatic_rifle": {
			_automatic_rifle = _value;
		};
		case "sniper_rifle": {
			_sniper_rifle = _value;
		};
		case "pistol": {
			_pistol = _value;
		};
		case "light_at": {
			_light_at = _value;
		};
		case "rifle_ammo": {
			_rifle_ammo = _value;
		};
		case "rifle_dmr_ammo": {
			_rifle_dmr_ammo = _value;
		};
		case "automatic_rifle_ammo": {
			_automatic_rifle_ammo = _value;
		};
		case "sniper_rifle_ammo": {
			_sniper_rifle_ammo = _value;
		};
		case "pistol_ammo": {
			_pistol_ammo = _value;
		};
		case "light_at_ammo": {
			_light_at_ammo = _value;
		};
		case "rifle_optic": {
			_rifle_optic = _value;
		};
		case "rifle_dmr_optic": {
			_rifle_dmr_optic = _value;
		};
		case "sniper_rifle_optic": {
			_sniper_rifle_optic = _value;
		};
		case "rifle_accessory": {
			_rifle_accessory = _value;
		};
		case "frag_grenade": {
			_frag_grenade = _value;
		};
		case "smoke_grenade": {
			_smoke_grenade = _value;
		};
		case "chemlight": {
			_chemlight = _value;
		};
		case "ir_grenade": {
			_ir_grenade = _value;
		};
		case "gl_he": {
			_gl_he = _value;
		};
		case "gl_flare_red": {
			_gl_flare_red = _value;
		};
		case "gl_flare_green": {
			_gl_flare_green = _value;
		};
		case "gl_smoke_red": {
			_gl_smoke_red = _value;
		};
		case "gl_smoke_green": {
			_gl_smoke_green = _value;
		};
	};
} forEach _faction_template;

// Remove existing items
removeAllWeapons player;
removeAllItems player;
removeAllAssignedItems player;
removeUniform player;
removeVest player;
removeBackpack player;
removeHeadgear player;
removeGoggles player;

// Add basic items
player linkItem "ItemMap";
player linkItem "ItemCompass";
player linkItem "ItemWatch";
player linkItem "ItemRadio";
if (_goggles != "") then {
	player linkItem _goggles;
};

// Add common items
["FirstAidKit", 1, "uniform"] call TH_fnc_addItem;
[_pistol_ammo, 2, "vest"] call TH_fnc_addItem;
[_smoke_grenade, 2, "vest"] call TH_fnc_addItem;
[_chemlight, 2, "vest"] call TH_fnc_addItem;
if (_ir_grenade != "") then {
	[_ir_grenade, 1, "vest"] call TH_fnc_addItem;
};

// Add loadout-specific items (primary weapon and ammo, frag grenades, etc.)
switch (_loadout) do {
	case "Grenadier":
	{
		[_rifle_ammo, 6, "vest"] call TH_fnc_addItem;
		[_frag_grenade, 2, "vest"] call TH_fnc_addItem;
		[_gl_he, 8, "vest"] call TH_fnc_addItem;
		[_gl_he, 14, "backpack"] call TH_fnc_addItem;
		[_gl_flare_green, 1, "backpack"] call TH_fnc_addItem;
		[_gl_flare_red, 1, "backpack"] call TH_fnc_addItem;
		[_gl_smoke_green, 1, "backpack"] call TH_fnc_addItem;
		[_gl_smoke_red, 1, "backpack"] call TH_fnc_addItem;
		player addWeapon _rifle_gl;
	};
	case "Automatic Rifleman":
	{
		[_automatic_rifle_ammo, 1, "vest"] call TH_fnc_addItem;
		[_automatic_rifle_ammo, 2, "backpack"] call TH_fnc_addItem;
		player addWeapon _automatic_rifle;
	};
	case "Designated Marksman":
	{
		[_rifle_dmr_ammo, 6, "vest"] call TH_fnc_addItem;
		[_frag_grenade, 2, "vest"] call TH_fnc_addItem;
		player addWeapon _rifle_dmr;
	};
	case "Light Anti-Tank":
	{
		[_rifle_ammo, 6, "vest"] call TH_fnc_addItem;
		[_frag_grenade, 2, "vest"] call TH_fnc_addItem;
		if (_light_at_ammo != "") then {
			[_light_at_ammo, 1, "backpack"] call TH_fnc_addItem;
		};
		player addWeapon _rifle;
		player addWeapon _light_at;
	};
	case "Combat Medic":
	{
		[_rifle_ammo, 6, "vest"] call TH_fnc_addItem;
		["FirstAidKit", 3, "backpack"] call TH_fnc_addItem;
		["Medikit", 1, "backpack"] call TH_fnc_addItem;
		player addWeapon _rifle_carbine;
	};
	case "Scout Sniper":
	{
		[_sniper_rifle_ammo, 6, "vest"] call TH_fnc_addItem;
		[_frag_grenade, 2, "vest"] call TH_fnc_addItem;
		player addWeapon _sniper_rifle

	};
	default
	{
		[_rifle_ammo, 6, "vest"] call TH_fnc_addItem;
		[_frag_grenade, 2, "vest"] call TH_fnc_addItem;
		player addWeapon _rifle;
	};
};

// Add secondary weapons after primary weapons so that primary weapon is selected
player addWeapon "Binocular";
player addWeapon _pistol;

// Add weapon attachements
switch (_loadout) do {
	case "Designated Marksman":
	{
		if (_rifle_dmr_optic != "") then {
			player addPrimaryWeaponItem _rifle_dmr_optic;
		};
	};
	case "Scout Sniper":
	{
		if (_sniper_rifle_optic != "") then {
			player addPrimaryWeaponItem _sniper_rifle_optic;
		};
	};
	default
	{
		if (_rifle_optic != "") then {
			player addPrimaryWeaponItem _rifle_optic;
		};
	}
};

if (_rifle_accessory != "") then {
	player addPrimaryWeaponItem _rifle_accessory;
};

true;