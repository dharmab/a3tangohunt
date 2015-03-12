_faction = _this select 0;
_faction_template = [] call compile preprocessFileLineNumbers format (["factions\%1.sqf", _faction]);

_faction_template;