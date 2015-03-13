/*
Determine the enemy faction.
@return (string) the enemy faction template name.
@see {fn_getFactions}
*/

_FACTION_TABLE = [] call TH_fnc_getFactions;
_description_ext_enemy_faction = ["EnemyFaction", 0] call BIS_fnc_getParamValue;
[_FACTION_TABLE, _description_ext_enemy_faction] call TH_fnc_lookupParameter;