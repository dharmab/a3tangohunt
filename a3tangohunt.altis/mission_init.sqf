// Forward declare runtime constants (parameters)
_PLAYER_FACTION = "";
_ENEMY_FACTION = "";
_ENEMY_MINIMUM_NUMBER = 0;
_ENEMY_SCALING_FACTOR = "";
_ENEMY_BEHAVIOR = 0.0;
_LOCATION_CLASSES = [];
_DAY = 0;
_TIME = 0;
_OVERCAST = 0.0;
_RAIN = 0.0;
_FOG = 0.0;
_ALLOW_UNDERWATER_START = false;

// Loads parameters from description.ext and initializes runtime constants
_fnc_initParameters = {
	// Value indicating that a parameter from description.ext should be randomized
	_RANDOMIZE = -1;

	// Parameters from description.ext
	_description_ext_player_faction = ["PlayerFaction", 0] call BIS_fnc_getParamValue;
	_description_ext_faction        = ["Faction", 1] call BIS_fnc_getParamValue;
	_description_ext_enemy_minimum  = ["EnemyMinimum", 0] call BIS_fnc_getParamValue;
	_description_ext_difficulty     = ["Difficulty", 1] call BIS_fnc_getParamValue;
	_description_ext_awareness      = ["Awareness", _RANDOMIZE] call BIS_fnc_getParamValue;
	_description_ext_location       = ["Location", 0] call BIS_fnc_getParamValue;
	_description_ext_time           = ["Time", _RANDOMIZE] call BIS_fnc_getParamValue;
	_description_ext_moon           = ["Moon", _RANDOMIZE] call BIS_fnc_getParamValue;
	_description_ext_weather        = ["Weather", _RANDOMIZE] call BIS_fnc_getParamValue;
	_description_ext_underwater     = ["Underwater", 0] call BIS_fnc_getParamValue;

	// Lookup tables - description.ext only supports int values, so we perform a lookup
	// to convert the parameters into runtime types

	// Player faction
	_PLAYER_FACTION_TABLE = ["NATO", "CSAT", "AAF", "FIA", "RHS USA", "RHS AFRF"];
	// Enemy faction
	_FACTION_TABLE = ["NATO", "CSAT", "AAF", "FIA", "RHS USA", "RHS AFRF", "CAF PIRATES", "CAF TRIBAL FIGHTERS", "CAF REBELS"];
	// Minimum number of enemies
	_ENEMY_MIN_TABLE = [1, 5, 10, 15, 20, 15, 30];
	// Enemy scaling factor
	_DIFFICULTY_TABLE = [1.0, 1.5, 2.0, 3.0];
	// Enemy behavior
	_AWARENESS_TABLE = ["SAFE", "AWARE", "COMBAT", "STEALTH"];
	// Location types - values are an array of location classnames, or empty array for a totally random position
	_LOCATION_TABLE = [[], ["NameCity","NameLocal", "NameVillage"], ["NameVillage"], ["NameCity"], ["NameLocal"]];
	// Time of day (values are hours)
	_TIME_TABLE = [0, 6, 9, 12, 15, 18];
	// Moon phase (values are days in July 2035)
	_MOON_TABLE = [5, 9, 12, 15, 20];
	// Overcast
	_OVERCAST_TABLE = [0.25, 0.5, 0.75, 0.85, 0.9];
	// Rain
	_RAIN_TABLE = [0.0,  0.0, 0.0,  0.67, 0.9];

	// Players will select from loadouts of this faction
	_PLAYER_FACTION = [_PLAYER_FACTION_TABLE, _description_ext_player_faction] call TH_fnc_lookupParameter;

	// Spawned enemies will be units of this faction
	_ENEMY_FACTION = [_FACTION_TABLE, _description_ext_faction] call TH_fnc_lookupParameter;

	// Minimum number of enemies to spawn
	_ENEMY_MINIMUM_NUMBER = [_ENEMY_MIN_TABLE, _description_ext_enemy_minimum] call TH_fnc_lookupParameter;

	// Factor used to scale the number of spawned enemies in relation to the number of players
	_ENEMY_SCALING_FACTOR = [_DIFFICULTY_TABLE, _description_ext_difficulty] call TH_fnc_lookupParameter;

	// Spawned enemies will be in this behavior mode at mission start
	_ENEMY_BEHAVIOR = [_AWARENESS_TABLE, _description_ext_awareness] call TH_fnc_lookupParameter;

	// Types of mission locations
	_LOCATION_CLASSES = [_LOCATION_TABLE, _description_ext_location] call TH_fnc_lookupParameter;

	// Day when mission will occur
	_DAY = [_MOON_TABLE, _description_ext_moon] call TH_fnc_lookupParameter;

	// Time of day at which mission will start
	_TIME = if (_description_ext_time == _RANDOMIZE) then {
		random 24;
	} else {
		[_TIME_TABLE, _description_ext_time] call TH_fnc_lookupParameter;
	};

	if (_description_ext_weather == _RANDOMIZE) then {
		_OVERCAST = random 1;

		// Weather engine only allows rain if overcast > 0.7
		// In addition, we add a 50% precipitation chance
		_RAIN = if ((_OVERCAST > 0.7) and ((random 1) > 0.5))  then {
			random 1;
		} else {
			0.0;
		};
	} else {
		_OVERCAST = [_OVERCAST_TABLE, _description_ext_weather] call TH_fnc_lookupParameter;
		_RAIN = [_RAIN_TABLE, _description_ext_weather] call TH_fnc_lookupParameter;
	};

	// Realistically, fog should not appear during the day
	// We limit fog to 0.7 because values above that are virtually unplayable "silent hill" values
	_FOG = if ((22 < _TIME) or (_TIME < 5)) then {
		0.1 + (random 0.6);
	} else {
		0.0;
	};

	// If set to true, players may spawn as scuba divers in water
	// Otherwise, players will only spawn as soldiers on land
	// 2014-10-29 disabled underwater starts due to incompatibility with new loadouts system
	_ALLOW_UNDERWATER_START = false;
};

// Set weather values across network
// _param_overcast overcast value (0.0 to 1.0)
// _param_rain rain value (0.0 to 1.0)
// _param_fog fog value (0.0 to 1.0)
_fnc_setWeather = {
	_param_overcast = _this select 0;
	_param_rain = _this select 1;
	_param_fog = _this select 2;

	[_param_overcast] call BIS_fnc_setOvercast;
	[_param_fog, _param_fog, 0] call BIS_fnc_setFog;

	_fnc_setRain = compile (format ["86400 setRain %1; skipTime 24; skipTime -24;", _param_rain]);
	[_fnc_setRain, "BIS_fnc_spawn", true, true] call BIS_fnc_MP;

	forceWeatherChange;
};

// Returns a random location on the map.
// _param_location_classes array of valid location classes
_fnc_randomizeEnemyLocation = {
	_param_location_classes = _this select 0;

	_location = "";
	if (count _param_location_classes == 0) then {
		// If no location classes were provided, create a new location 
		_location_position = [] call TH_fnc_getRandomLandPosition;
		_location_position = _location_position + [0];
		_location = createLocation ["NameLocal", _location_position, 150 + random 200, 150 + random 200];
	} else {
		_locations = [];
		waitUntil {
			_random_position = [] call TH_fnc_getRandomLandPosition;

			// Get all viable locations within 1km of the random position
			_locations = nearestLocations [_random_position, _param_location_classes, 1000];

			// Ensure at least one location was found
			count _locations > 0;
		};
		// Return a random location
		_location = _locations call BIS_fnc_selectRandom;
	};
	_location;
};

// Returns a random position 500 meters away from the provided position.
// _param_enemy_position position to base returned position on.
_fnc_randomizePlayerPosition = {
	_param_enemy_position = _this select 0;
	_water_mode = if (_ALLOW_UNDERWATER_START) then {1} else {0};

	_random_position = [_param_enemy_position, 335, 475, 1, _water_mode, 100, 0] call BIS_fnc_findSafePos;

	_random_position;
};

// Expose a variable to the public mission namespace
// _name variable name
// _value variable value
_fnc_exportToPublicMissionNamespace = {
	_name = _this select 0;
	_value = _this select 1;
	missionNamespace setVariable [_name, _value];
	publicVariable _name;
};

if (!isServer) exitWith {};

// Initialize parameters
[] call _fnc_initParameters;

// Set weather, date and time
[_OVERCAST, _RAIN, _FOG] call _fnc_setWeather;
[(24 * _DAY) + _TIME, true, false] call BIS_fnc_setDate;

// Random area selection
_area_location = [_LOCATION_CLASSES] call _fnc_randomizeEnemyLocation;
_area_marker = createMarker ["enemy_area", position _area_location];
_area_marker setMarkerSize (size _area_location);

// Create objective marker and set symbology
_task_marker = createMarker ["task_marker", (getMarkerPos _area_marker)];
_task_marker setMarkerShape "ICON";
_task_marker setMarkerType "mil_objective";
_task_marker setMarkerColor "ColorRed";

// Create insertion marker and set symbology
_insertion_marker_position = [getMarkerPos _area_marker] call _fnc_randomizePlayerPosition;
_insertion_marker = createMarker ["player_start", _insertion_marker_position];
_insertion_marker setMarkerShape "ICON";
_insertion_marker setMarkerType "mil_start";
_insertion_marker setMarkerColor "ColorBlue";

// Spawn enemies
_number_of_enemies = ceil ((playersNumber west) * _ENEMY_SCALING_FACTOR);
if (_number_of_enemies < _ENEMY_MINIMUM_NUMBER) then {
	_number_of_enemies = _ENEMY_MINIMUM_NUMBER;
};
_enemies = [_area_marker, east, _ENEMY_FACTION, _number_of_enemies, _ENEMY_BEHAVIOR] call TH_fnc_spawnEnemies;

// Allow Zeus to manipulate/take control of spawned enemies
game_master_module addCuratorEditableObjects [_enemies, false];

// Move players to start
_player_direction = [getMarkerPos "player_start", getMarkerPos "task_marker"] call TH_fnc_computeAngle;
[compile format 
	["player setDir %1; player setPos (getMarkerPos ""player_start"");", _player_direction],
"BIS_fnc_spawn", true, true] call BIS_fnc_MP;

// Set flag for clients and other scripts to continue
["mission_tangohunt_init", true] call _fnc_exportToPublicMissionNamespace;
