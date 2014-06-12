waitUntil {!isNil "BIS_fnc_init"};
// Specify possible area markers here and in description.ext
// Each marker must be an area marker with a corresponding point marker with the suffix "_Start"
// e.g. "My_Town" must have a nearby "My_Town_Start" marker
_area_markers_array = [
	"Agrios_Forest",
	"Panagia",
	"Sofia_Power_Plant",
	"Nidasos_West_Village",
	"Ghost_Hotel",
	"Charkia_Storage",
	"Chapel_Hill",
	"Kavala_Suburbs",
	"Abdera",
	"Abandoned_House",
	"Junkyard"
];

// Utility functions
fnc_setWeather = {
	// Make sure to turn off auto weather in the mission editor!
	_param_overcast = _this select 0;
	_param_rain     = _this select 1;
	_param_fog      = _this select 2;
	
	[_param_overcast] call BIS_fnc_setOvercast;

	// todo BIS_fnc_setFog
	86400 setFog _param_fog;
	86400 setRain _param_rain;
	forceWeatherChange;
	0 = [] spawn {
		sleep 0.1;
		simulWeatherSync;
	};
};

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
		random 24;
	} else {
		_param_time;
	};

	_overcast = 0.0;
	_rain = 0.0;

	if (_param_weather == -1) then {
		 _overcast = random 1;
		 // Rain only works if overcast is at least 0.7
		 // Also, 50% chance of rain even with clouds
		 _var = random 1;
		 _rain = if ((_overcast > 0.7) and (_var > 0.5))  then {
			random 1;
		} else {
			0.0;
		};
	} else {
		switch (_param_weather) do {
			// Clear
			case 0:
			{
				_overcast = 0.0;
				_rain = 0.0;
			};
			// Partly cloudy
			case 1:
			{
				_overcast = 0.3;
				_rain = 0.0;
			};
			// Cloudy
			case 2:
			{
				_overcast = 0.5;
				_rain = 0.0;
			};
			// Raining
			case 3:
			{
				_overcast = 0.7;
				_rain = 0.5;
			};
			// Thunderstorm
			case 4:
			{
				_overcast = 0.9;
				_rain = 0.9;
			};
			// You changed description.ext and didn't update this code
			default
			{
				_overcast = 0.0;
				_rain = 0.0;
			};
		};
	};

	_fog = if ((22 < _time) or (_time < 5)) then {
		0.0;
	} else {
		0.1 + (random 0.6);
	};

	_area_marker = if (_param_area == -1) then {
		_area_markers_array call BIS_fnc_selectRandom;
	} else {
		_area_markers_array select _param_area;
	};

	// Get all playable units for enemy strength auto-balance
	// We have to check dead units as well since players start out in the respawn menu
	_all_players_array = playableUnits;
	{
		if (isPlayer _x) then {
			_all_players_array = _all_players_array + [_x];
		};
	} forEach allDeadMen;

	// Spawn AI
	_enemy_faction = ["CSAT", "AAF", "FIA"] select _param_enemy_faction;
	_enemy_strength = if (_param_enemy_strength == -1) then {
	_player_count = count _all_players_array;
		ceil (_player_count * 3) / 2;
	} else {
		_param_enemy_strength;
	};

	[_area_marker, east, _enemy_faction, _enemy_strength] execVM "tangohunt.sqf";

	// Export variables used for client-local commands below
	missionNamespace setVariable ["mission_time", _time];
	missionNamespace setVariable ["mission_overcast", _overcast];
	missionNamespace setVariable ["mission_rain", _rain];
	missionNamespace setVariable ["mission_fog", _fog];
	missionNamespace setVariable ["mission_area_marker", _area_marker];
	publicVariable "mission_time";
	publicVariable "mission_overcast";
	publicVariable "mission_rain";
	publicVariable "mission_fog";
	publicVariable "mission_area_marker";

	// Set flags for clients to begin script
	missionNamespace setVariable ["mission_tangohunt_init", true];
	publicVariable "mission_tangohunt_init";
};

// Wait for server to finish
waitUntil {missionNamespace getVariable "mission_tangohunt_init";};

// Retreive variables calculated on the server
_time        = missionNamespace getVariable "mission_time";
_overcast    = missionNamespace getVariable "mission_overcast";
_rain        = missionNamespace getVariable "mission_rain";
_fog         = missionNamespace getVariable "mission_fog";
_area_marker = missionNamespace getVariable "mission_area_marker";

// Initialize weather and time
[_overcast, _rain, _fog] call fnc_setWeather;
skipTime _time;

// Create objective marker
createMarker ["task_marker", (getMarkerPos _area_marker)];
"task_marker" setMarkerShape "ICON";
"task_marker" setMarkerType "mil_objective";
"task_marker" setMarkerText "Secure Area";
"task_marker" setMarkerColor "ColorRed";

// Grab the existing Start marker and make it visible
_insertion_marker = format["%1_Start", _area_marker];
_insertion_marker setMarkerShape "ICON";
_insertion_marker setMarkerType "mil_start";
_insertion_marker setMarkerColor "ColorBlue";

// Set the spawn location
"respawn_west" setMarkerPos (getMarkerPos _insertion_marker);

// Create task for objective
[player, "task_objective", [
	"Attack the enemy infantry force and secure the area.",
	"Secure the area",
	"task_marker"
], objNull, true] call BIS_fnc_taskCreate;

["TaskAssigned", ["Secure area"]] call BIS_fnc_showNotification;