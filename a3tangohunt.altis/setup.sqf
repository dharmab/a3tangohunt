waitUntil {!isNil "BIS_fnc_init"};

// Constants
// Code indicating that a parameter from description.ext should be randomized
_RANDOMIZE = -1;

// Specify possible area markers here and in description.ext
// Each marker must be an area marker with a corresponding point marker with the suffix "_Start"
// e.g. "My_Town" must have a nearby "My_Town_Start" marker
_AREA_MARKERS = [
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
	true;
};

fnc_randomizeEnemyLocation = {
	_random_position = [0, 0];
	waitUntil {
		_random_position = [random 25000, random 25000];
		(getTerrainHeightASL _random_position) >= 10;
	};

	_location_type = ["NameCity", "NameVillage"] call BIS_fnc_selectRandom;
	// "Name" is the parent class of all named locations
	nearestLocation [_random_position, _location_type];
};

fnc_randomizePlayerPosition = {
	_param_enemy_position = _this select 0;

	_random_position = [0, 0];
	waitUntil {
		_x_offset = random 500;
		_y_offset = 500 - _x_offset;
		if (random 1 > 0.5) then {_x_offset = _x_offset * -1};
		if (random 1 > 0.5) then {_y_offset = _y_offset * -1};

		_random_position = [
			(_param_enemy_position select 0) + _x_offset, 
			(_param_enemy_position select 1) + _y_offset
		];

		(getTerrainHeightASL _random_position) >= 10;
	};

	_random_position;
};

fnc_tangoHunt = {
	_param_area_marker = _this select 0;
	_param_enemy_side = _this select 1;
	_param_enemy_faction = _this select 2;
	_param_enemy_strength = _this select 3;
	_param_player_side = _this select 4;
	// Initialize the mission
	_all_enemies_array = [_area_marker, east, _enemy_faction, _enemy_strength] call compile preprocessFileLineNumbers "tangohunt.sqf";
	// Spawn the victory/defeat condition loop in a new thread
	[_param_player_side] spawn {_this call compile preprocessFileLineNumbers "endCheck.sqf"};
};

{_x setMarkerAlpha 0.0;} forEach _AREA_MARKERS;

// Flag that indicates when server init is complete
missionNamespace setVariable ["mission_tangohunt_init", false];

if (isServer) then {
	// Parameters from description.ext
	_param_enemy_faction  = paramsArray select 0;
	_param_enemy_strength = paramsArray select 1;
	_param_area           = paramsArray select 2;
	_param_time           = paramsArray select 3;
	_param_moon_phase     = paramsArray select 4;
	_param_weather        = paramsArray select 5;

	// Set number of days to skip to force a certain moon phase
	_day = if (_param_moon_phase == _RANDOMIZE) then {
		[5, 9, 12, 15, 20] call BIS_fnc_selectRandom;
	} else {
		_param_moon_phase;
	};

	// Set numbers of hours to skip to force a certain time of day
	_time = if (_param_time == _RANDOMIZE) then {
		random 24;
	} else {
		_param_time;
	};

	// Set weather values
	_overcast = 0.0;
	_rain = 0.0;

	if (_param_weather == _RANDOMIZE) then {
		// Randomization
		 _overcast = random 1;
		 // Rain only works if overcast is at least 0.7
		 // Also, we add a 50% chance of no rain for more variety
		 _rain_chance = random 1;
		 _rain = if ((_overcast > 0.7) and (_rain_chance > 0.5))  then {
			random 1;
		} else {
			0.0;
		};
	} else {
		// Manual selection
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

	// Fog only appears between dusk and dawn
	_fog = if ((22 < _time) or (_time < 5)) then {
		0.1 + (random 0.6);
	} else {
		0.0;
	};

	// Area selection
	_area_location = [] call fnc_randomizeEnemyLocation;
	_area_position = [position _area_location select 0, position _area_location select 1];
	_area_marker = createMarker ["enemy_area", _area_position];
	_area_marker setMarkerSize (size _area_location);

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
	_enemy_strength = if (_param_enemy_strength == _RANDOMIZE) then {
		_player_count = count _all_players_array;
		ceil ((_player_count * 3) / 2);
	} else {
		_param_enemy_strength;
	};

	[_area_marker, east, _enemy_faction, _enemy_strength, west] call fnc_tangoHunt;

	// Export variables used for client-local commands below
	missionNamespace setVariable ["mission_time", _time];
	missionNamespace setVariable ["mission_day", _day];
	missionNamespace setVariable ["mission_overcast", _overcast];
	missionNamespace setVariable ["mission_rain", _rain];
	missionNamespace setVariable ["mission_fog", _fog];
	missionNamespace setVariable ["mission_area_marker", _area_marker];
	publicVariable "mission_time";
	publicVariable "mission_day";
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
_day         = missionNamespace getVariable "mission_day";
_overcast    = missionNamespace getVariable "mission_overcast";
_rain        = missionNamespace getVariable "mission_rain";
_fog         = missionNamespace getVariable "mission_fog";
_area_marker = missionNamespace getVariable "mission_area_marker";

// Initialize weather, date and time
[_overcast, _rain, _fog] call fnc_setWeather;
skipTime (_time + (24 * _day));

// Create objective marker
createMarker ["task_marker", (getMarkerPos _area_marker)];
"task_marker" setMarkerShape "ICON";
"task_marker" setMarkerType "mil_objective";
"task_marker" setMarkerText "Secure Area";
"task_marker" setMarkerColor "ColorRed";

// Grab the existing Start marker and make it visible

_insertion_marker_position = [getMarkerPos _area_marker] call fnc_randomizePlayerPosition;
_insertion_marker = createMarker ["player_start", _insertion_marker_position];
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
