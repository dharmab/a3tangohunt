/*
Mission initialization logic

This script handles the randomization elements of Tango Hunt.

* Sets time, weather and moon phase
* Selects mission area
* Adds map markers
* Auto-balances mission
* Spawns enemies
* Spawns player vehicles

*/
if (!isServer) exitWith {};

// Forward declare runtime constants (parameters)
_PLAYER_FACTION = "";
_PLAYER_NUMBER_OF_CARS = 0;
_PLAYER_NUMBER_OF_APCS = 0;
_PLAYER_NUMBER_OF_TANKS = 0;
_ENEMY_FACTION = "";
_ENEMY_NUMBER_OF_INFANTRY = 0;
_ENEMY_NUMBER_OF_CARS = 0;
_ENEMY_NUMBER_OF_APCS = 0;
_ENEMY_NUMBER_OF_TANKS = 0;
_ENEMY_SCALING_FACTOR = "";
_ENEMY_BEHAVIOR = "";
_FRIENDLY_NUMBER_OF_INFANTRY = 0;
_FRIENDLY_NUMBER_OF_CARS = 0;
_FRIENDLY_NUMBER_OF_APCS = 0;
_FRIENDLY_NUMBER_OF_TANKS = 0;
_LOCATION_CLASSES = [];
_DAY = 0;
_TIME = 0;
_OVERCAST = 0.0;
_RAIN = 0.0;
_FOG = 0.0;

/*
Loads parameters from description.ext and initializes runtime constants
@return nothing
*/
_fnc_initParameters = {
	// Value indicating that a parameter from description.ext should be randomized
	_RANDOMIZE = -1;
	// Value indicating that a parameter from description.ext should be auto-balanced
	_AUTO_BALANCE = -2;

	// Parameters from description.ext
	_description_ext_player_cars       = ["PlayerCars", 0] call BIS_fnc_getParamValue;
	_description_ext_player_apcs       = ["PlayerApcs", 0] call BIS_fnc_getParamValue;
	_description_ext_player_tanks      = ["PlayerTanks", 0] call BIS_fnc_getParamValue;
	_description_ext_enemy_infantry    = ["EnemyInfantry", 1] call BIS_fnc_getParamValue;
	_description_ext_enemy_cars        = ["EnemyCars", _AUTO_BALANCE] call BIS_fnc_getParamValue;
	_description_ext_enemy_apcs        = ["EnemyApcs", _AUTO_BALANCE] call BIS_fnc_getParamValue;
	_description_ext_enemy_tanks       = ["EnemyTanks", _AUTO_BALANCE] call BIS_fnc_getParamValue;
	_description_ext_friendly_infantry = ["FriendlyInfantry", 0] call BIS_fnc_getParamValue;
	_description_ext_friendly_cars     = ["FriendlyCars", 0] call BIS_fnc_getParamValue;
	_description_ext_friendly_apcs     = ["FriendlyApcs", 0] call BIS_fnc_getParamValue;
	_description_ext_friendly_tanks    = ["FriendlyTanks", 0] call BIS_fnc_getParamValue;
	_description_ext_difficulty        = ["Difficulty", 1] call BIS_fnc_getParamValue;
	_description_ext_awareness         = ["Awareness", _RANDOMIZE] call BIS_fnc_getParamValue;
	_description_ext_location          = ["Location", 0] call BIS_fnc_getParamValue;
	_description_ext_time              = ["Time", _RANDOMIZE] call BIS_fnc_getParamValue;
	_description_ext_moon              = ["Moon", _RANDOMIZE] call BIS_fnc_getParamValue;
	_description_ext_weather           = ["Weather", _RANDOMIZE] call BIS_fnc_getParamValue;

	// Lookup tables - description.ext only supports int values, so we perform a lookup
	// to convert the parameters into runtime types
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
	_PLAYER_FACTION = [] call TH_fnc_getPlayerFaction;

	// Number of empty vehicles to spawn for the players
	_PLAYER_NUMBER_OF_CARS = _description_ext_player_cars;
	_PLAYER_NUMBER_OF_APCS = _description_ext_player_apcs;
	_PLAYER_NUMBER_OF_TANKS = _description_ext_player_tanks;

	// Spawned enemies will be units of this faction
	_ENEMY_FACTION = [] call TH_fnc_getEnemyFaction;

	// Factor used to scale the number of spawned enemies in relation to the number of players
	_ENEMY_SCALING_FACTOR = [_DIFFICULTY_TABLE, _description_ext_difficulty] call TH_fnc_lookupParameter;

	// Minimum number of friendly AI to spawn
	_FRIENDLY_NUMBER_OF_INFANTRY = _description_ext_friendly_infantry;
	_FRIENDLY_NUMBER_OF_CARS = _description_ext_friendly_cars;
	_FRIENDLY_NUMBER_OF_APCS = _description_ext_friendly_apcs;
	_FRIENDLY_NUMBER_OF_TANKS = _description_ext_friendly_tanks;

	// Minimum number of enemies to spawn
	_ENEMY_NUMBER_OF_INFANTRY = if (_description_ext_enemy_infantry == _AUTO_BALANCE) then {
		ceil ((_FRIENDLY_NUMBER_OF_INFANTRY + playersNumber west) * _ENEMY_SCALING_FACTOR);
	} else {
		_description_ext_enemy_infantry
	};
	if (_ENEMY_NUMBER_OF_INFANTRY < 5) then {
		_ENEMY_NUMBER_OF_INFANTRY = 5;
	};

	// Number of enemy vehicles to spawn
	_ENEMY_NUMBER_OF_CARS = if (_description_ext_enemy_cars == _AUTO_BALANCE) then {
		_PLAYER_NUMBER_OF_CARS + _FRIENDLY_NUMBER_OF_CARS;
	} else {
		_description_ext_enemy_cars;
	};
	_ENEMY_NUMBER_OF_APCS = if (_description_ext_enemy_apcs == _AUTO_BALANCE) then {
		_PLAYER_NUMBER_OF_APCS + _FRIENDLY_NUMBER_OF_APCS;
	} else {
		_description_ext_enemy_apcs;
	};
	_ENEMY_NUMBER_OF_TANKS = if (_description_ext_enemy_tanks == _AUTO_BALANCE) then {
		_PLAYER_NUMBER_OF_TANKS + _FRIENDLY_NUMBER_OF_TANKS;
	} else {
		_description_ext_enemy_tanks;
	};

	// Spawned enemies will be in this behavior mode at mission start
	_ENEMY_BEHAVIOR = [_AWARENESS_TABLE, _description_ext_awareness] call TH_fnc_lookupParameter;

	// Types of mission locations
	_LOCATION_CLASSES = [_LOCATION_TABLE, _description_ext_location] call TH_fnc_lookupParameter;

	// Day when mission will occur
	_DAY = [_MOON_TABLE, _description_ext_moon] call TH_fnc_lookupParameter;

	// Time of day at which mission will start
	_RANDOMIZE_DAYLIGHT = -2;
	_TIME = switch (_description_ext_time) do { 
		case _RANDOMIZE: {
			random 24;
		}; 
		case _RANDOMIZE_DAYLIGHT: {
			6 + random 12;
		}; 
		default {
			[_TIME_TABLE, _description_ext_time] call TH_fnc_lookupParameter;
		}; 
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
	true;
};

/*
Set weather values on server and all clients.
@param _param_overcast (number) overcast value (0.0 to 1.0)
@param _param_rain (number) rain value (0.0 to 1.0)
@param _param_fog (number) fog value (0.0 to 1.0)
@return nothing
*/
_fnc_setWeather = {
	_param_overcast = _this select 0;
	_param_rain = _this select 1;
	_param_fog = _this select 2;

	[_param_overcast] call BIS_fnc_setOvercast;
	[_param_fog, _param_fog, 0] call BIS_fnc_setFog;

	_fnc_setRain = compile (format ["86400 setRain %1; skipTime 24; skipTime -24;", _param_rain]);
	[_fnc_setRain, "BIS_fnc_spawn", true, true] call BIS_fnc_MP;

	forceWeatherChange;
	true;
};

/*
Find a random location for the enemy area
@param _param_location_classes (array) location classes to select from. If the empty array is passed, a new location is
generated from a random land position.
@return (location) a random location
*/
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

/*
@return (boolean) true if either player or enemy faction has vehicles. False otherwise.
*/
_fnc_vehiclesArePresent = {
	_number_of_player_vehicles = _PLAYER_NUMBER_OF_TANKS + _PLAYER_NUMBER_OF_APCS + _PLAYER_NUMBER_OF_CARS;
	_number_of_friendly_vehicles = _FRIENDLY_NUMBER_OF_TANKS + _FRIENDLY_NUMBER_OF_APCS + _FRIENDLY_NUMBER_OF_CARS;
	_number_of_enemy_vehicles = _ENEMY_NUMBER_OF_TANKS + _ENEMY_NUMBER_OF_APCS + _ENEMY_NUMBER_OF_CARS;
	(_number_of_player_vehicles > 0) || (_number_of_friendly_vehicles > 0) || (_number_of_enemy_vehicles > 0);
};

/*
Find a random position for the player spawn
@param _param_enemy_position (position2d) enemy position
@return (position2d) a player spawn position. If vehicles are present, the spawn position is further away to compensate for the increase
in weapon ranges.
*/
_fnc_randomizePlayerPosition = {
	_param_enemy_position = _this select 0;

	_distance =	300 + (25 * ((playersNumber west) + _FRIENDLY_NUMBER_OF_INFANTRY));

	_max_distance = 800;
	if ([] call _fnc_vehiclesArePresent || _distance > _max_distance) then {
		_distance = _max_distance;
	};

	_random_position = [_param_enemy_position, _distance - 75, _distance + 75, 1, 0, 100, 0] call BIS_fnc_findSafePos;

	_random_position;
};

/* Expose a variable to the public mission namespace
@param _param_name (string) variable name
@param _param_value (any) variable value
@return nothing
*/
_fnc_exportToPublicMissionNamespace = {
	_param_name = _this select 0;
	_param_value = _this select 1;
	missionNamespace setVariable [_param_name, _param_value];
	publicVariable _param_name;
};

// Initialize parameters
[] call _fnc_initParameters;

// Set weather, date and time
[_OVERCAST, _RAIN, _FOG] call _fnc_setWeather;
[(24 * _DAY) + _TIME, true, false] call BIS_fnc_setDate;

// Random area selection
_enemy_location = [_LOCATION_CLASSES] call _fnc_randomizeEnemyLocation;
_enemy_marker = createMarker ["enemy_area", position _enemy_location];
_enemy_marker setMarkerSize (size _enemy_location);

// Create objective marker and set symbology
_task_marker = createMarker ["task_marker", (getMarkerPos _enemy_marker)];
_task_marker setMarkerShape "ICON";
_task_marker setMarkerType "mil_objective";
_task_marker setMarkerColor "ColorRed";

// Create visible insertion marker and set symbology
_insertion_marker_position = [getMarkerPos _enemy_marker] call _fnc_randomizePlayerPosition;
_insertion_marker = createMarker ["player_start", _insertion_marker_position];
_insertion_marker setMarkerShape "ICON";
_insertion_marker setMarkerType "mil_start";
_insertion_marker setMarkerColor "ColorBlue";

// Create invisible insertion marker for spawning friendly AI
_friendly_marker = createMarker ["friendly_area", _insertion_marker_position];
_friendly_marker setMarkerSize [75, 75];

// Spawn friendlies
_friendlies = [
	_friendly_marker,
	west,
	_PLAYER_FACTION,
	"AWARE",
	_FRIENDLY_NUMBER_OF_INFANTRY,
	_FRIENDLY_NUMBER_OF_CARS,
	_FRIENDLY_NUMBER_OF_APCS,
	_FRIENDLY_NUMBER_OF_TANKS
] call TH_fnc_spawnEnemies;

// Spawn enemies
_enemies = [
	_enemy_marker,
	east,
	_ENEMY_FACTION,
	_ENEMY_BEHAVIOR,
	_ENEMY_NUMBER_OF_INFANTRY,
	_ENEMY_NUMBER_OF_CARS,
	_ENEMY_NUMBER_OF_APCS,
	_ENEMY_NUMBER_OF_TANKS
] call TH_fnc_spawnEnemies;

_enemy_marker_position = getMarkerPos _enemy_marker;
_enemy_marker_size = ((getMarkerSize _enemy_marker select 0) + (getMarkerSize _enemy_marker select 1)) / 2.0;

_enemy_groups = [];
{
	// Keep track of which groups we set waypoints for
	_enemy_group = group _x;
	if (!(_enemy_group in _enemy_groups)) then {
		_enemy_groups append [_enemy_group];

		// Either order the group to patrol the area or defend their location
		if (random 1 < 0.67) then {
			[_enemy_group, getPos _x, 250] call BIS_fnc_taskPatrol;
		} else {
			[_enemy_group, getPos _x] call BIS_fnc_taskDefend;
		};
	};
} forEach _enemies;

_friendly_groups = [];
{
	// Keep track of which groups we set waypoints for
	_friendly_group = group _x;
	if (!(_friendly_group in _friendly_groups)) then {
		_friendly_groups append [_friendly_group];

		// Add a Seek and Destroy waypoint
		_attack_waypoint = _friendly_group addWaypoint [_enemy_marker_position, _enemy_marker_size];
		_attack_waypoint setWaypointType "SAD";
	};
} forEach _friendlies;

// Allow Zeus to manipulate/take control of spawned enemies
game_master_module addCuratorEditableObjects [_enemies, false];
game_master_module addCuratorEditableObjects [_friendlies, false];

// Move players to start
_player_direction = [getMarkerPos "player_start", getMarkerPos "task_marker"] call TH_fnc_computeAngle;
[compile format
	["player setDir %1; player setPos (getMarkerPos ""player_start"");", _player_direction],
"BIS_fnc_spawn", true, true] call BIS_fnc_MP;

// Spawn player vehicles
[
	_PLAYER_FACTION,
	getMarkerPos "player_start",
	_player_direction,
	_PLAYER_NUMBER_OF_CARS,
	_PLAYER_NUMBER_OF_APCS,
	_PLAYER_NUMBER_OF_TANKS
] call TH_fnc_spawnVehicles;

// Set flag for clients and other scripts to continue
["mission_tangohunt_init", true] call _fnc_exportToPublicMissionNamespace;
true;
