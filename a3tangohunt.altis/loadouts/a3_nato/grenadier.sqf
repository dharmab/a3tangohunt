comment "Exported from Arsenal by Zaid";
_player = _this select 0;

comment "Remove existing items";
removeAllWeapons _player;
removeAllItems _player;
removeAllAssignedItems _player;
removeUniform _player;
removeVest _player;
removeBackpack _player;
removeHeadgear _player;
removeGoggles _player;

comment "Add containers";
_player forceAddUniform "U_B_CombatUniform_mcam";
_player addItemToUniform "FirstAidKit";
_player addVest "V_PlateCarrierGL_rgr";
for "_i" from 1 to 2 do {_player addItemToVest "16Rnd_9x21_Mag";};
for "_i" from 1 to 2 do {_player addItemToVest "SmokeShell";};
for "_i" from 1 to 2 do {_player addItemToVest "Chemlight_green";};
for "_i" from 1 to 2 do {_player addItemToVest "HandGrenade";};
for "_i" from 1 to 6 do {_player addItemToVest "30Rnd_65x39_caseless_mag";};
_player addItemToVest "B_IR_Grenade";
for "_i" from 1 to 6 do {_player addItemToVest "1Rnd_HE_Grenade_shell";};
_player addBackpack "B_AssaultPack_mcamo";
for "_i" from 1 to 14 do {_player addItemToBackpack "1Rnd_HE_Grenade_shell";};
_player addItemToBackpack "UGL_FlareGreen_F";
_player addItemToBackpack "UGL_FlareRed_F";
for "_i" from 1 to 2 do {_player addItemToBackpack "1Rnd_Smoke_Grenade_shell";};
_player addItemToBackpack "1Rnd_SmokeRed_Grenade_shell";
_player addItemToBackpack "1Rnd_SmokeGreen_Grenade_shell";
_player addHeadgear "H_HelmetB";

comment "Add weapons";
_player addWeapon "arifle_MX_GL_Black_F";
_player addPrimaryWeaponItem "acc_pointer_IR";
_player addPrimaryWeaponItem "optic_Aco";
_player addWeapon "hgun_P07_F";
_player addWeapon "Binocular";

comment "Add items";
_player linkItem "ItemMap";
_player linkItem "ItemCompass";
_player linkItem "ItemWatch";
_player linkItem "ItemRadio";
_player linkItem "NVGoggles";
