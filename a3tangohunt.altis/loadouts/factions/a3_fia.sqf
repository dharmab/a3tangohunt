_loadout = _this select 1;

// Uniform
_uniform = "U_BG_Guerrilla_6_1";
// Armor vest/ammo rig
_vest = "V_Chestrig_oli";
// Armor vest/ammo rig for Grenadier
_vest_gl = "V_Chestrig_oli";
// Backpack
_backpack = "B_FieldPack_oli";
// Helmet or headgear. Set to empty string for no headgear.
_headgear = "H_Cap_oli";
// Night vision goggles. Set to empty string for no night vision goggles.
_goggles = "";

// Primary weapon for Light Anti-Tank
_rifle = "arifle_Mk20C_F";
// Primary weapon for Grenadier 
_rifle_gl = "arifle_Mk20_GL_F";
// Primary weapon for Medic
_rifle_carbine = "arifle_Mk20C_F";
// Primary weapon for Designated Marksman
_rifle_dmr = "arifle_Mk20_F";
// Primary weapon for Automatic Rifleman
_automatic_rifle = "LMG_Mk200_F";
// Secondary weapon for all loadouts
_pistol = "hgun_ACPC2_F";
// Launcher for Light Anti-Tank
_light_at = "RPG32_F";

// Ammo for Light Anti-Tank and Grenadier primary weapon
_rifle_ammo = "30Rnd_556x45_Stanag";
// Ammo for Designated Marksman primary weapon
_rifle_dmr_ammo = "30Rnd_556x45_Stanag";
// Ammo for Automatic Rifleman primary weapon
_automatic_rifle_ammo = "200Rnd_65x39_cased_Box";
// Ammo for secondary weapon
_pistol_ammo = "9Rnd_45ACP_Mag";
// Ammo for Light Anti-Tank launcher
_light_at_ammo = "launch_RPG32_F";

// Optic used on all primary weapons except Designated Marksman. Set to empty string for iron sights.
_rifle_optic = "";
// Optic used on Designated Marksman primary weapon. Set to empty string for iron sights.
_rifle_dmr_optic = "optic_DMS";
// Primary weapon accessory, e.g. IR pointer or flashlight. Set to empty string for no accessory.
_rifle_accessory = "acc_flashlight";

// Fragmentation grenade
_frag_grenade = "HandGrenade";
// Smoke grenade
_smoke_grenade = "SmokeShell";
// Chemical light
_chemlight = "Chemlight_green";
// Infrared marker. Set to empty string for no IR grenades.
_ir_grenade = "";

// Grenade launcher high-explosive round
_gl_he = "1Rnd_HE_Grenade_shell";
// Grenade launcher red flare round
_gl_flare_red = "UGL_FlareRed_F";
// Grenade launcher green flare round
_gl_flare_green = "UGL_FlareGreen_F";
// Grenade launcher red smoke round
_gl_smoke_red = "1Rnd_SmokeRed_Grenade_shell";
// Grenade launcher green smoke round
_gl_smoke_green = "1Rnd_SmokeGreen_Grenade_shell";

[
    _loadout,
    _uniform,
    _vest,
    _vest_gl,
    _backpack,
    _headgear,
    _goggles,
    _rifle,
    _rifle_gl,
    _rifle_carbine,
    _rifle_dmr,
    _automatic_rifle,
    _pistol,
    _light_at,
    _rifle_ammo,
    _rifle_dmr_ammo,
    _automatic_rifle_ammo,
    _pistol_ammo,
    _light_at_ammo,
    _rifle_optic,
    _rifle_dmr_optic,
    _rifle_accessory,
    _frag_grenade,
    _smoke_grenade,
    _chemlight,
    _ir_grenade,
    _gl_he,
    _gl_flare_red,
    _gl_flare_green,
    _gl_smoke_red,
    _gl_smoke_green
] call TH_fnc_applyLoadout;