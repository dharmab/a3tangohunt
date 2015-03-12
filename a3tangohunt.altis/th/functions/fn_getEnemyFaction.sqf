_FACTION_TABLE = [] call TH_fnc_getFactions;
_description_ext_enemy_faction = ["EnemyFaction", 0] call BIS_fnc_getParamValue;
[_FACTION_TABLE, _description_ext_enemy_faction] call TH_fnc_lookupParameter;