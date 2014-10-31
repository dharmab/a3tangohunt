_area_marker           = _this select 0; // marker
_ai_side               = _this select 1; // west, east, resistance
_ai_faction            = _this select 2; // "NATO", "FIA", "AAF", "CSAT"
_ai_global_count_total = _this select 3; // integer > 0
_ai_behavior           = _this select 4; // "CARELESS", "SAFE", "AWARE", "COMBAT", "STEALTH"

_ai_team_leader = "";
_ai_rifleman = "";
_ai_machinegunner = "";
_ai_marksman = "";
_ai_antitank = "";

switch (_ai_faction) do  {
	// Bohemia Interactive: NATO (Arma 3)
	case "NATO":
	{
		_ai_team_leader   = "B_Soldier_TL_F";
		_ai_rifleman      = "B_Soldier_F";
		_ai_machinegunner = "B_soldier_AR_F";
		_ai_marksman      = "B_soldier_M_F";
		_ai_antitank      = "B_soldier_LAT_F";
	};
	// Bohemia Interactive: FIA
	case "FIA":
	{
		_ai_team_leader   = "I_G_Soldier_TL_F";
		_ai_rifleman      = "I_G_Soldier_F";
		_ai_machinegunner = "I_G_soldier_AR_F";
		_ai_marksman      = "I_G_soldier_M_F";
		_ai_antitank      = "I_G_soldier_LAT_F";
	};
	// Bohemia Interactive: AAF
	case "AAF":
	{
		_ai_team_leader   = "I_Soldier_TL_F";
		_ai_rifleman      = "I_Soldier_F";
		_ai_machinegunner = "I_soldier_AR_F";
		_ai_marksman      = "I_soldier_M_F";
		_ai_antitank      = "I_soldier_LAT_F";
	};
	// Bohemia Interactive: CSAT
	case "CSAT":
	{
		_ai_team_leader   = "O_Soldier_TL_F";
		_ai_rifleman      = "O_Soldier_F";
		_ai_machinegunner = "O_soldier_AR_F";
		_ai_marksman      = "O_soldier_M_F";
		_ai_antitank      = "O_soldier_LAT_F";
	};
	// Robert Hammer Studios: Armed Forces of the Russian Federation
	case "RHS AFRF":
	{
		_ai_team_leader   = "rhs_vdv_sergeant";
		_ai_rifleman      = "rhs_vdv_rifleman";
		_ai_machinegunner = "rhs_vdv_machinegunner";
		_ai_marksman      = "rhs_vdv_marksman";
		_ai_antitank      = "rhs_vdv_LAT";
	};
	// Robert Hammer Studios: United States Armed Forces
	case "RHS USA":
	{
		_ai_team_leader   = "rhsusf_army_ocp_teamleader";
		_ai_rifleman      = "rhsusf_army_ocp_rifleman";
		_ai_machinegunner = "rhsusf_army_ocp_autorifleman";
		_ai_marksman      = "rhsusf_army_ocp_marksman";
		_ai_antitank      = "rhsusf_army_ocp_LAT";
	};
	// Canadian Armed Forces Team: African Pirates
	case "CAF PIRATES":
	{
		_ai_team_leader   = "CAF_AG_AFR_P_AK74";
		_ai_rifleman      = "CAF_AG_AFR_P_AK74";
		_ai_machinegunner = "CAF_AG_AFR_P_RPK74";
		_ai_marksman      = "CAF_AG_AFR_P_SVD";
		_ai_antitank      = "CAF_AG_AFR_P_RPG";
	};
	// Canadian Armed Forces Team: Middle Eastern Tribal Fighters
	case "CAF TRIBAL FIGHTERS":
	{
		_ai_team_leader   = "CAF_AG_ME_T_AK74";
		_ai_rifleman      = "CAF_AG_ME_T_AK74";
		_ai_machinegunner = "CAF_AG_ME_T_RPK74";
		_ai_marksman      = "CAF_AG_ME_T_SVD";
		_ai_antitank      = "CAF_AG_ME_T_RPG";
	};
	// Canadian Armed Forces Team: Eastern European Rebels
	case "CAF REBELS":
	{
		_ai_team_leader   = "CAF_AG_EEUR_R_AK74";
		_ai_rifleman      = "CAF_AG_EEUR_R_AK74";
		_ai_machinegunner = "CAF_AG_EEUR_R_PKM";
		_ai_marksman      = "CAF_AG_EEUR_R_SVD";
		_ai_antitank      = "CAF_AG_EEUR_R_RPG";
	};
	default {
		hint "Error: _ai_faction parameter invalid";
	};
};

if (_ai_global_count_total < 1) then {
	hint "Error: _ai_global_count_total parameter invalid";
};

// Possibilities for number of AI spawned in a group
_ai_group_count_distribution = if (_ai_global_count_total <= 5) then {
	[1, 2, 2, 3];
} else {
	[1, 2, 2, 3, 4, 4, 4, 4, 5, 6];
};
// Possibilities for class of AI spawned in a group; Groups above a certain size always have a team leader
_ai_group_class_distribution = [_ai_rifleman, _ai_rifleman, _ai_rifleman, _ai_rifleman, _ai_machinegunner, _ai_machinegunner, _ai_marksman, _ai_antitank]; 

_area_marker_position = getMarkerPos _area_marker;
_area_marker_size = ((getMarkerSize _area_marker select 0) + (getMarkerSize _area_marker select 1)) / 2.0;

_ai_units = [];
while {(count _ai_units) < _ai_global_count_total} do {
	_ai_count_group_total = _ai_group_count_distribution call BIS_fnc_selectRandom;

	_new_group = createGroup _ai_side;
	_new_group_position = [_area_marker_position, 25, 150, 1, 0, 100, 0] call BIS_fnc_findSafePos;

	// Groups with 4 or more members have a team leader
	if (_ai_count_group_total >= 4) then {
		_ai_team_leader createUnit [_new_group_position, _new_group];
	};
	
	while {(count (units _new_group)) < _ai_count_group_total} do {
		(_ai_group_class_distribution call BIS_fnc_selectRandom) createUnit [_new_group_position, _new_group];
	};

	// Add several patrol waypoints and a final defend waypoint to the new group
	[_new_group, getPos leader _new_group, 250] call BIS_fnc_taskPatrol;
	_defend_waypoint = _new_group addWaypoint [_area_marker_position, _area_marker_size];
	_defend_waypoint setWaypointType "MOVE";
	_defend_waypoint setWaypointStatements ["true", "nul = [group this, position this] call BIS_fnc_taskDefend;"];

	_new_group setBehaviour _ai_behavior;
	
	_ai_units = _ai_units + units _new_group;
};

_ai_units;
