_loadout = _this select 1;

// Uniform
_uniform = "rhs_uniform_cu_ocp";
// Uniform for Divers
_uniform_diver = "U_B_Wetsuit";

// Armor vest/ammo rig
_vest = "rhsusf_iotv_ocp_Rifleman";
// Armor vest/ammo rig for Grenadier
_vest_gl = "rhsusf_iotv_ocp_Grenadier";
// Rebreather vest for Divers
_vest_diver = "V_RebreatherB";

// Backpack
_backpack = "rhsusf_assault_eagleaiii_ocp";
// Helmet or headgear. Set to empty string for no headgear.
_headgear = "rhsusf_ach_helmet_ocp";
// Night vision goggles. Set to empty string for no night vision goggles.
_goggles = "NVGoggles";

// Primary weapon for Light Anti-Tank
_rifle = "rhs_weap_m4";
// Primary weapon for Grenadier 
_rifle_gl = "rhs_m4_m320";
// Primary weapon for Medic
_rifle_carbine = "rhs_weap_m4";
// Primary weapon for Designated Marksman
_rifle_dmr = "rhs_weap_m4";
// Primary weapon for Automatic Rifleman
_automatic_rifle = "rhs_weap_m249_pip";
// Primary weapon for Divers
_rifle_diver = "arifle_SDAR_F";
// Secondary weapon for all loadouts
_pistol = "hgun_P07_F";
// Launcher for Light Anti-Tank
_light_at = "rhs_weap_M136";

// Ammo for Light Anti-Tank and Grenadier primary weapon
_rifle_ammo = "rhs_mag_30Rnd_556x45_Mk318_Stanag";
// Ammo for Designated Marksman primary weapon
_rifle_dmr_ammo = "rhs_mag_30Rnd_556x45_Mk318_Stanag";
// Ammo for Automatic Rifleman primary weapon
_automatic_rifle_ammo = "rhsusf_100Rnd_556x45_soft_pouch";
// ammo for Diver primary weapon
_rifle_diver_ammo = "20Rnd_556x45_UW_mag";
// Ammo for secondary weapon
_pistol_ammo = "16Rnd_9x21_Mag";
// Ammo for Light Anti-Tank launcher
_light_at_ammo = "rhs_m136_mag";

// Optic used on all primary weapons except Designated Marksman. Set to empty string for iron sights.
_rifle_optic = "rhsusf_acc_compm4";
// Optic used on Designated Marksman primary weapon. Set to empty string for iron sights.
_rifle_dmr_optic = "rhsusf_acc_HAMR";
// Primary weapon accessory, e.g. IR pointer or flashlight. Set to empty string for no accessory.
_rifle_accessory = "rhsusf_acc_anpeq15A";

// Fragmentation grenade
_frag_grenade = "HandGrenade";
// Smoke grenade
_smoke_grenade = "SmokeShell";
// Chemical light
_chemlight = "Chemlight_green";
// Infrared marker. Set to empty string for no IR grenades.
_ir_grenade = "B_IR_Grenade";

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
    _uniform_diver,
    _vest,
    _vest_gl,
    _vest_diver,
    _backpack,
    _headgear,
    _goggles,
    _rifle,
    _rifle_gl,
    _rifle_carbine,
    _rifle_dmr,
    _automatic_rifle,
    _rifle_diver,
    _pistol,
    _light_at,
    _rifle_ammo,
    _rifle_dmr_ammo,
    _automatic_rifle_ammo,
    _rifle_diver_ammo,
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