_area_marker = _this select 0;
_ai_side = _this select 1;
_ai_faction = _this select 2;
_num_of_ai_min_total = _this select 3;

fnc_select_random = {_this select floor(random count(_this))};

_ai_team_leader = "";
_ai_rifleman = "";
_ai_machinegunner = "";
_ai_sniper = "";
_ai_antitank = "";

switch (_ai_faction) do  {
	case "NATO":
	{
		_ai_team_leader = "B_Soldier_TL_F";
		_ai_rifleman = "B_Soldier_F";
		_ai_machinegunner = "B_soldier_AR_F";
		_ai_sniper = "B_soldier_M_F";
		_ai_antitank = "B_soldier_LAT_F";
	};
	case "FIA":
	{
		_ai_team_leader = "I_G_Soldier_TL_F";
		_ai_rifleman = "I_G_Soldier_F";
		_ai_machinegunner = "I_G_soldier_AR_F";
		_ai_sniper = "I_G_soldier_M_F";
		_ai_antitank = "I_G_soldier_LAT_F";
	};
	case "AAF":
	{
		_ai_team_leader = "I_Soldier_TL_F";
		_ai_rifleman = "I_Soldier_F";
		_ai_machinegunner = "I_soldier_AR_F";
		_ai_sniper = "I_soldier_M_F";
		_ai_antitank = "I_soldier_LAT_F";
	};
	case "CSAT":
	{
		_ai_team_leader = "O_Soldier_TL_F";
		_ai_rifleman = "O_Soldier_F";
		_ai_machinegunner = "O_soldier_AR_F";
		_ai_sniper = "O_soldier_M_F";
		_ai_antitank = "O_soldier_LAT_F";
	};
};

_num_of_ai = 0;
while {_num_of_ai < _num_of_ai_min_total} do {
	_num_of_ai_this_group_total = [1, 1, 2, 2, 3, 4, 4, 4, 5, 6] call fnc_select_random;
	_num_of_ai_this_group = 0;
	_temp_group = createGroup _ai_side;

	if (_num_of_ai_this_group_total >= 4) then {
		_ai_team_leader createUnit [[0, 0, 0], _temp_group];
		_num_of_ai_this_group = _num_of_ai_this_group + 1;
	};
	
	while {_num_of_ai_this_group < _num_of_ai_this_group_total} do {
		([_ai_rifleman, _ai_rifleman, _ai_rifleman, _ai_rifleman, _ai_machinegunner, _ai_machinegunner, _ai_sniper, _ai_antitank] call fnc_select_random) createUnit [[0, 0, 0], _temp_group];
		_num_of_ai_this_group = _num_of_ai_this_group + 1;
	};
	[leader _temp_group, _area_marker, "random"] execVM "UPS.sqf";
	_num_of_ai = _num_of_ai + _num_of_ai_this_group;
};
