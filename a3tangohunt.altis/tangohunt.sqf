_area_marker           = _this select 0; // marker
_ai_side               = _this select 1; // west, east, resistance
_ai_faction            = _this select 2; // "NATO", "FIA", "AAF", "CSAT"
_ai_global_count_total = _this select 3; // integer > 0

_ai_team_leader = "";
_ai_rifleman = "";
_ai_machinegunner = "";
_ai_marksman = "";
_ai_antitank = "";

switch (_ai_faction) do  {
	case "NATO":
	{
		_ai_team_leader   = "B_Soldier_TL_F";
		_ai_rifleman      = "B_Soldier_F";
		_ai_machinegunner = "B_soldier_AR_F";
		_ai_marksman      = "B_soldier_M_F";
		_ai_antitank      = "B_soldier_LAT_F";
	};
	case "FIA":
	{
		_ai_team_leader   = "I_G_Soldier_TL_F";
		_ai_rifleman      = "I_G_Soldier_F";
		_ai_machinegunner = "I_G_soldier_AR_F";
		_ai_marksman      = "I_G_soldier_M_F";
		_ai_antitank      = "I_G_soldier_LAT_F";
	};
	case "AAF":
	{
		_ai_team_leader   = "I_Soldier_TL_F";
		_ai_rifleman      = "I_Soldier_F";
		_ai_machinegunner = "I_soldier_AR_F";
		_ai_marksman      = "I_soldier_M_F";
		_ai_antitank      = "I_soldier_LAT_F";
	};
	case "CSAT":
	{
		_ai_team_leader   = "O_Soldier_TL_F";
		_ai_rifleman      = "O_Soldier_F";
		_ai_machinegunner = "O_soldier_AR_F";
		_ai_marksman      = "O_soldier_M_F";
		_ai_antitank      = "O_soldier_LAT_F";
	};
	default {
		hint "Error: _ai_faction parameter invalid";
	};
};

if (_ai_global_count_total < 1) then {
	hint "Error: _ai_global_count_total parameter invalid";
};

// Possibilities for number of AI spawned in a group
_ai_group_count_distribution = [1, 2, 2, 3, 4, 4, 4, 4, 5, 6];
// Possibilities for class of AI spawned in a group; Groups above a certain size always have a team leader
_ai_group_class_distribution = [_ai_rifleman, _ai_rifleman, _ai_rifleman, _ai_rifleman, _ai_machinegunner, _ai_machinegunner, _ai_marksman, _ai_antitank]; 

_ai_units = [];
while {(count _ai_units) < _ai_global_count_total} do {
	_ai_count_group_total = _ai_group_count_distribution call BIS_fnc_selectRandom;

	_new_group = createGroup _ai_side;

	if (_ai_count_group_total >= 4) then {
		_ai_team_leader createUnit [[0, 0, 0], _new_group];
	};
	
	while {(count (units _new_group)) < _ai_count_group_total} do {
		(_ai_group_class_distribution call BIS_fnc_selectRandom) createUnit [[0, 0, 0], _new_group];
	};

	[leader _new_group, _area_marker, "random"] execVM "UPS.sqf";

	_ai_units = _ai_units + units _new_group;
};

_ai_units;