waitUntil {!isNil "bis_fnc_init"};

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

//Set the parameters
_time = if (_param_time == -1) then {
	[0, 6, 9, 12, 15, 18] call BIS_fnc_selectRandom;
} else {
	_param_time;
};

skipTime -24;
_weather = if (_param_weather == -1) then {
	[0.0, 0.3, 0.5, 0.7, 1.0] call BIS_fnc_selectRandom;
} else {
	_param_weather;
};

86400 setOvercast _weather;
if (_weather > 0.5) then {86400 setRain _weather};
skipTime 24;

skipTime _time;

_enemy_faction = ["CSAT", "AAF", "FIA"] select _param_enemy_faction;

_enemy_strength = if (_param_enemy_strength == -1) then {
	(count _all_players_array * 3) / 2;
} else {
	_param_enemy_strength;
};

_area_marker = if (_param_area == -1) then {
	_area_markers_array call BIS_fnc_selectRandom;
} else {
	_area_markers_array select _param_area;
};

_insertion_marker = format["%1_Start", _area_marker];

// And move the players to the start
{_x setPos (getMarkerPos _insertion_marker)} forEach _all_players_array;

// Place a visible marker on the AO
createMarker ["objective", getMarkerPos _area_marker];
"objective" setMarkerShape "ICON";
"objective" setMarkerText "Clear Area";
"objective" setMarkerType "mil_destroy";

// Place a victory condition trigger on the AO
_victory_trigger = createTrigger ["EmptyDetector", getMarkerPos _area_marker];
_xrad = round ((GetMarkerSize _area_marker select 0) / 2);
_yrad = round ((GetMarkerSize _area_marker select 1) / 2);
_victory_trigger setTriggerArea [_xrad, _yrad, 0, true];
_victory_trigger setTriggerActivation ["WEST SEIZED", "PRESENT", false];
_victory_trigger setTriggerStatements ["this", "hint 'NATO Victory'", ""];

// Place a global defeat condition trigger 
_defeat_trigger = createTrigger ["EmptyDetector", [0, 0, 0]];
_defeat_trigger setTriggerStatements [format ["count (units group_hq + units group_alpha + units group_bravo + units group_charlie) < (%1 / 2)", count _all_players_array], "hint 'Enemy Victory'", ""];

// Spawn enemies in AO
[_area_marker, east, _enemy_faction, _enemy_strength] execVM "tangohunt.sqf";