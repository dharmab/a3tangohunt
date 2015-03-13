/*
Determine the player faction.
@return (string) the player faction template name.
@see {fn_getFactions}
*/
_FACTION_TABLE = [] call TH_fnc_getFactions;
_description_ext_player_faction = ["PlayerFaction", 0] call BIS_fnc_getParamValue;
[_FACTION_TABLE, _description_ext_player_faction] call TH_fnc_lookupParameter;
