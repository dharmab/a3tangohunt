waitUntil {!isNil "BIS_fnc_init"};

// Utility functions
fnc_setWeather = {
	// Make sure to turn off auto weather in the mission editor!
	_param_overcast = _this select 0;
	_param_rain     = _this select 1;
	_param_fog      = _this select 2;
	
	[_param_overcast] call BIS_fnc_setOvercast;

	// todo BIS_fnc_setFog
	skipTime -24;
	86400 setFog _param_fog;
	86400 setRain _param_rain;
	skipTime 24;
	0 = [] spawn {
		sleep 0.1;
		simulWeatherSync;
	};
};

// Specify possible area markers here and in description.ext
_area_markers_array = [
	"Agrios_Forest",
	"Panagia"
];


{_x setMarkerAlpha 0.0;} forEach _area_markers_array;

// Flag that indicates when server init is complete
missionNamespace setVariable ["mission_tangohunt_init", false];

if (isServer) then {
	// Parameters from description.ext
	_param_enemy_faction  = paramsArray select 0;
	_param_enemy_strength = paramsArray select 1;
	_param_area           = paramsArray select 2;
	_param_time           = paramsArray select 3;
	_param_weather        = paramsArray select 4;

	// Sync random parameters across network
	_time = if (_param_time == -1) then {
		[0, 6, 9, 12, 15, 18] call BIS_fnc_selectRandom;
	} else {
		_param_time;
	};

	_weather = if (_param_weather == -1) then {
		 [0.0, 0.3, 0.5, 0.7, 1.0] call BIS_fnc_selectRandom;
	} else {
		_param_weather;
	};

	_area_marker = if (_param_area == -1) then {
		_area_markers_array call BIS_fnc_selectRandom;
	} else {
		_area_markers_array select _param_area;
	};

	// Get all playable units for enemy strength auto-balance
	_all_players_array = [];

	if (isMultiplayer) then {
		_all_players_array = playableUnits;
	} else {
		_all_players_array =
			units group_hq +
			units group_alpha +
			units group_bravo +
			units group_charlie;
	};
	// We have to check dead units as well since players start out in the respawn menu
	{
		if (isPlayer _x) then {
			_all_players_array = _all_players_array + [_x];
		};
	} forEach allDeadMen;

	// Spawn AI
	_enemy_faction = ["CSAT", "AAF", "FIA"] select _param_enemy_faction;

	_enemy_strength = if (_param_enemy_strength == -1) then {
	_player_count = count _all_players_array;
		logic_radio globalChat (format ["AUTO-BALANCE: %1 PLAYER(S) DETECTED", _player_count]);
		ceil (_player_count * 3) / 2;
	} else {
		_param_enemy_strength;
	};

	[_area_marker, east, _enemy_faction, _enemy_strength] execVM "tangohunt.sqf";

	missionNamespace setVariable ["mission_time", _time];
	missionNamespace setVariable ["mission_weather", _weather];
	missionNamespace setVariable ["mission_area_marker", _area_marker];
	missionNamespace setVariable ["mission_tangohunt_init", true];
	publicVariable "mission_time";
	publicVariable "mission_weather";
	publicVariable "mission_area_marker";
	publicVariable "mission_tangohunt_init";
};

waitUntil {mission_tangohunt_init};

// Initialize weather and time
_overcast = missionNamespace getVariable "mission_weather";

_rain = if (_overcast > 0.7) then {
	(1 - _overcast) * 3.0;
} else {
	0.0;
};

_fog = if (_overcast > 0.5) then {
	_overcast - 0.25;
} else {
	_overcast * 0;
};

[_overcast, _rain, _fog] call fnc_setWeather;

skipTime (missionNamespace getVariable "mission_time");

// Initialize visible markers
_area_marker = missionNamespace getVariable "mission_area_marker";

createMarker ["task_marker", (getMarkerPos _area_marker)];
"task_marker" setMarkerShape "ICON";
"task_marker" setMarkerType "mil_objective";
"task_marker" setMarkerText "Secure Area";
"task_marker" setMarkerColor "ColorRed";

_insertion_marker = format["%1_Start", _area_marker];
_insertion_marker setMarkerShape "ICON";
_insertion_marker setMarkerType "mil_start";
_insertion_marker setMarkerColor "ColorBlue";

// Set the spawn location
"respawn_west" setMarkerPos (getMarkerPos _insertion_marker);

// Create task
[player, "task_objective", [
	"Attack the enemy infantry force and secure the area.",
	"Secure the area",
	"task_marker"
], objNull, true] call BIS_fnc_taskCreate;

["TaskAssigned", ["Secure area"]] call BIS_fnc_showNotification;

