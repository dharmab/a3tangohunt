/*
Look up a faction template by name.
@param _param_faction_template_name (string) A faction template name.
@return (array) The faction template
*/
_param_faction_template_name = _this select 0;
_faction_template = [] call compile preprocessFileLineNumbers format (["factions\%1.sqf", _param_faction_template_name]);

_faction_template;
