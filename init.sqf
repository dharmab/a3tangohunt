waitUntil {!isNil "bis_fnc_init"};

execVM "briefing.sqf";

// Parameters from description.ext
_param_enemy_faction  = paramsArray select 0;
_param_enemy_strength = paramsArray select 1;
_param_area           = paramsArray select 2;
_param_time           = paramsArray select 3;
_param_weather        = paramsArray select 4;

//Specify possible area markers here and in description.ext
_area_markers_array = [
	"Test_Alpha",
	"Test_Bravo"
];

{_x setMarkerAlpha 0.0;} forEach _area_markers_array;

_all_players_array =
	units group_hq +
	units group_alpha +
	units group_bravo +
	units group_charlie;

// Utility functions
fnc_setWeather = {
	// Make sure to turn off auto weather in the mission editor!
	_param_overcast = _this select 0;
	_param_rain     = _this select 1;
	_param_fog      = _this select 2;
	
	skipTime -24;
	86400 setOvercast _param_overcast;
	86400 setRain _param_rain;
	86400 setFog _param_fog;
	skipTime 24;
};

// Process parameters
_enemy_faction = ["CSAT", "AAF", "FIA"] select _param_enemy_faction;

_enemy_strength = if (_param_enemy_strength == -1) then {
	(count _all_players_array * 3) / 2;
} else {
	_param_enemy_strength;
};

_time = if (_param_time == -1) then {
	[0, 6, 9, 12, 15, 18] call BIS_fnc_selectRandom;
} else {
	_param_time;
};

_overcast = if (_param_weather == -1) then {
	[0.0, 0.3, 0.5, 0.7, 1.0] call BIS_fnc_selectRandom;
} else {
	_param_weather;
};

_rain = if (_overcast > 0.5) then {
	_overcast;
} else {
	0.0;
};

_fog = if (_overcast > 0.5) then {
	_overcast - 0.25;
} else {
	0.0;
};

_area_marker = if (_param_area == -1) then {
	_area_markers_array call BIS_fnc_selectRandom;
} else {
	_area_markers_array select _param_area;
};

// Initialize mission
[_overcast, _rain, _fog] call fnc_setWeather;

skipTime _time;

createMarker ["task_marker", getMarkerPos _area_marker]
"task_marker" setMarkerShape "ICON";
"task_marker" setMarkerType "mil_objective";
"task_marker" setMarkerText "Secure Area";

_insertion_marker = format["%1_Start", _area_marker];
_insertion_marker setMarkerShape "ICON";
_insertion_marker setMarkerType "Start";
_insertion_marker setMarkerColor "ColorBlue";

{_x setPos (getMarkerPos _insertion_marker)} forEach _all_players_array;

[player, "task_objective", ["Attack the enemy infantry force and secure the area.", "Secure the area", "task_marker"], objNull, true] call BIS_fnc_taskCreate;  
["TaskAssigned", ["Attack the enemy"]] call BIS_fnc_showNotification;

_xrad = round ((GetMarkerSize _area_marker select 0) / 2);
_yrad = round ((GetMarkerSize _area_marker select 1) / 2);

_victory_trigger = createTrigger ["EmptyDetector", getMarkerPos _area_marker];
_victory_trigger setTriggerArea [_xrad, _yrad, 0, true];
_victory_trigger setTriggerActivation ["WEST SEIZED", "PRESENT", false];
_victory_trigger setTriggerStatements [
	"this",
	"nul = execVM 'victory.sqf';",
	""
];

_defeat_trigger = createTrigger ["EmptyDetector", [0, 0, 0]];
_defeat_trigger setTriggerStatements [
	format ["count (units group_hq + units group_alpha + units group_bravo + units group_charlie) < (%1 / 2)", count _all_players_array],
	 "nul = execVM 'defeat.sqf';",
	 ""
];

[_area_marker, east, _enemy_faction, _enemy_strength] execVM "tangohunt.sqf";
