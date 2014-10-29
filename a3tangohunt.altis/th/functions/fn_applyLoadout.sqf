_loadout = _this select 0;
_uniform = _this select 1;
_vest = _this select 2;
_vest_gl = _this select 3;
_backpack = _this select 4;
_headgear = _this select 5;
_goggles = _this select 6;
_rifle = _this select 7;
_rifle_gl = _this select 8;
_rifle_carbine = _this select 9;
_rifle_dmr = _this select 10;
_automatic_rifle = _this select 11;
_pistol = _this select 12;
_light_at = _this select 13;
_rifle_ammo = _this select 14;
_rifle_dmr_ammo = _this select 15;
_automatic_rifle_ammo = _this select 16;
_pistol_ammo = _this select 17;
_light_at_ammo = _this select 18;
_rifle_optic = _this select 19;
_rifle_dmr_optic = _this select 20;
_rifle_accessory = _this select 21;
_frag_grenade = _this select 22;
_smoke_grenade = _this select 23;
_chemlight = _this select 24;
_ir_grenade = _this select 25;
_gl_he = _this select 26;
_gl_flare_red = _this select 27;
_gl_flare_green = _this select 28;
_gl_smoke_red = _this select 29;
_gl_smoke_green = _this select 30;

// Remove existing items
removeAllWeapons player;
removeAllItems player;
removeAllAssignedItems player;
removeUniform player;
removeVest player;
removeBackpack player;
removeHeadgear player;
removeGoggles player;

player forceAddUniform _uniform;
if (_loadout == "Grenadier") then {
    player addVest _vest_gl;
} else {
    player addVest _vest;
};
player addBackpack _backpack;
if (_headgear != "") then {
    player addHeadgear _headgear;
};

player linkItem "ItemMap";
player linkItem "ItemCompass";
player linkItem "ItemWatch";
player linkItem "ItemRadio";
if (_goggles != "") then {
    player linkItem _goggles;
};

["FirstAidKit", 1, "uniform"] call TH_fnc_addItem;
[_pistol_ammo, 2, "vest"] call TH_fnc_addItem;
[_smoke_grenade, 2, "vest"] call TH_fnc_addItem;
[_chemlight, 2, "vest"] call TH_fnc_addItem;
if (_ir_grenade != "") then {
    [_ir_grenade, 1, "vest"] call TH_fnc_addItem;
};

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
        [_frag_grenade, 2, "vest"] call TH_fnc_addItem;
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
        [_light_at_ammo, 1, "backpack"] call TH_fnc_addItem;
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
    default{
        [_rifle_ammo, 6, "vest"] call TH_fnc_addItem;
        [_frag_grenade, 2, "vest"] call TH_fnc_addItem;
        player addWeapon _rifle;
    }
};

player addWeapon "Binocular";
player addWeapon _pistol;

if (_loadout == "Designated Marksman" and _rifle_dmr_optic != "") then {
    player addPrimaryWeaponItem _rifle_dmr_optic;
} else {
    if (_rifle_optic != "") then {
        player addPrimaryWeaponItem _rifle_optic;
    };
};