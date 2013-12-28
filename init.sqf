//Specify possible area markers here and in description.ext
_area_markers = ["Chalkeia", "Dorida", "Feres", "Panagia", "Selakano"];
_airfield_marker = "airfield";

//Get parameters
_param_enemy_faction = paramsArray select 0;
_param_enemy_strength = paramsArray select 1;
_param_area = paramsArray select 2;
_param_time = paramsArray select 3;
_param_weather = paramsArray select 4;

_num_of_players = 
	count units group_hq + 
	count units group_alpha + 
	count units group_bravo + 
	count units group_charlie;

//Utility functions
fnc_select_random = {_this select floor(random count(_this))};

fnc_moveInCargoGroup = {{{_x moveInCargo (_this select 1);} forEach units _x;} forEach (_this select 0);};

//Hide all markers
{_x setMarkerAlpha 0.0;} forEach _area_markers;

//Set the time
_time = 0;

//Set the weather
_overcast = 0.0;

if (_param_weather == -1) then {
	_overcast = [0.0, 0.3, 0.5, 0.7, 1.0] call fnc_select_random;
} else {
	_overcast = _param_weather;
};
skipTime -24;
86400 setOvercast _overcast;
skipTime 24;

if (_param_time == -1) then {
	_time = [0, 6, 9, 12, 15, 18] call fnc_select_random;
} else {
	_time = _param_time;
};
skipTime ((_time - daytime + 24 ) % 24);

//Set the enemy faction
_enemy_faction = ["CSAT", "AAF", "FIA"] select _param_enemy_faction;

//Set the number of enemies
_enemy_strength = -1;

if (_param_enemy_strength == -1) then {
	_enemy_strength = round((_num_of_players * 3) / 2);
} else {
	_enemy_strength = _param_enemy_strength;
};

//Set the area
_area_marker = "";

if (_param_area == -1) then {
	_area_marker = _area_markers call fnc_select_random;
} else {
	_area_marker = _area_markers select _param_area;
};


//Move the players into the helicopters
[[group_hq, group_alpha], ghosthawk_1] call fnc_moveInCargoGroup;
[[group_bravo, group_charlie], ghosthawk_2] call fnc_moveInCargoGroup;

//Set the helicopter waypoints
_lz = (group ghosthawk_1) addWaypoint [getMarkerPos _area_marker, 500, 0];
[(group ghosthawk_1), 0] setWaypointCombatMode "Yellow";
[(group ghosthawk_1), 0] setWaypointBehaviour "STEALTH";
[(group ghosthawk_1), 0] setWaypointType "TR UNLOAD";
_lz setWaypointStatements ["true", "{_x disableai 'target';_x disableai 'autotarget';_x disableai 'fsm';} forEach thislist;"];

(group ghosthawk_1) addWaypoint [getMarkerPos _airfield_marker, 50, 1];
[(group ghosthawk_1), 1] setWaypointCombatMode "Red";
[(group ghosthawk_1), 1] setWaypointBehaviour "CARELESS";
[(group ghosthawk_1), 1] setWaypointType "MOVE";

(group ghosthawk_1) setCurrentWaypoint [(group ghosthawk_1), 0];

//Put a marker on the AO
createMarker ["objective", getMarkerPos _area_marker];
"objective" setMarkerShape "ICON";
"objective" setMarkerText "Clear Area";
"objective" setMarkerType "mil_destroy";

//Put a victory condition trigger on the AO
_victory_trigger = createTrigger ["EmptyDetector", getMarkerPos _area_marker];
_xrad = round ((GetMarkerSize _area_marker select 0) / 2);
_yrad = round ((GetMarkerSize _area_marker select 1) / 2);
_victory_trigger setTriggerArea [_xrad, _yrad, 0, true];
_victory_trigger setTriggerActivation ["WEST SEIZED", "PRESENT", false];
_victory_trigger setTriggerStatements ["this", "hint 'NATO Victory'", ""];

//Put a global defeat condition trigger 
_defeat_trigger = createTrigger ["EmptyDetector", [0, 0, 0]];
_defeat_trigger setTriggerStatements [format ["count (units group_hq + units group_alpha + units group_bravo + units group_charlie) < (%1 / 2)", _num_of_players], "hint 'Enemy Victory'", ""];

//Spawn enemies in AO
[_area_marker, east, _enemy_faction, _enemy_strength] execVM "tangohunt.sqf";