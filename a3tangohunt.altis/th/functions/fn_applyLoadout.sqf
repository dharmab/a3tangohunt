_loadout              = _this select 0;
_uniform              = _this select 1;
_uniform_diver        = _this select 2;
_vest                 = _this select 3;
_vest_gl              = _this select 4;
_vest_diver           = _this select 5;
_backpack             = _this select 6;
_headgear             = _this select 7;
_goggles              = _this select 8;
_rifle                = _this select 9;
_rifle_gl             = _this select 10;
_rifle_carbine        = _this select 11;
_rifle_dmr            = _this select 12;
_automatic_rifle      = _this select 13;
_rifle_diver          = _this select 14;
_pistol               = _this select 15;
_light_at             = _this select 16;
_rifle_ammo           = _this select 17;
_rifle_dmr_ammo       = _this select 18;
_automatic_rifle_ammo = _this select 19;
_rifle_diver_ammo     = _this select 20;
_pistol_ammo          = _this select 21;
_light_at_ammo        = _this select 22;
_rifle_optic          = _this select 23;
_rifle_dmr_optic      = _this select 24;
_rifle_accessory      = _this select 25;
_frag_grenade         = _this select 26;
_smoke_grenade        = _this select 27;
_chemlight            = _this select 28;
_ir_grenade           = _this select 29;
_gl_he                = _this select 30;
_gl_flare_red         = _this select 31;
_gl_flare_green       = _this select 32;
_gl_smoke_red         = _this select 33;
_gl_smoke_green       = _this select 34;

_is_diver = (_loadout == "Diver (Assault)" or _loadout == "Diver (Medic)");

// Remove existing items
removeAllWeapons player;
removeAllItems player;
removeAllAssignedItems player;
removeUniform player;
removeVest player;
removeBackpack player;
removeHeadgear player;
removeGoggles player;

// Add uniform, vest, backpack and headgear
if (_is_diver) then {
	player forceAddUniform _vest_diver;
	player addVest _vest_diver;
} else {
	player forceAddUniform _uniform;
	if (_loadout == "Grenadier") then {
		player addVest _vest_gl;
	} else {
		if (_is_diver) then {
		} else {
			player addVest _vest;
		};
	};
	player addBackpack _backpack;
	if (_headgear != "") then {
		player addHeadgear _headgear;
	};
};

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
		[_rifle_ammo, 6, "vest"] call TH_fnc_addItem;
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
	case "Diver (Assault)":
	{
		[_rifle_diver_ammo, 4, "vest"] call TH_fnc_addItem;
		[_frag_grenade, 2, "vest"] call TH_fnc_addItem;
		player addWeapon _rifle_diver;
	};
	case "Diver (Medic)":
	{
		[_rifle_diver_ammo, 4, "vest"] call TH_fnc_addItem;
		["FirstAidKit", 1, "vest"] call TH_fnc_addItem;
		["Medikit", 1, "vest"] call TH_fnc_addItem;
		player addWeapon _rifle_diver;
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

if (!_is_diver) then {
	// Add weapon attachements
	if (_loadout == "Designated Marksman" and _rifle_dmr_optic != "") then {
		player addPrimaryWeaponItem _rifle_dmr_optic;
	} else {
		if (_rifle_optic != "") then {
			player addPrimaryWeaponItem _rifle_optic;
		};
	};

	if (_rifle_accessory != "") then {
		player addPrimaryWeaponItem _rifle_accessory;
	};
};
