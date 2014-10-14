// Code indicating that a parameter from description.ext should be randomized
_RANDOMIZE = -1;

_fnc_computeOffset = {
	_param_origin = _this select 0;
	_param_distance = _this select 1;
	_param_angle = _this select 2;

	// Sanitize angle
	_angle = _param_angle % 360;
	if (_angle < 0) then {
	    _angle = 360 + _angle;
	};

	// use the quadrant and angle to determine ratio and sign of x and y offsets
	_x_offset_direction = 1;
	_y_offset_direction = 1;
	_x_to_y_ratio = 0.0;
	if (0 <= _angle && _angle < 90) then {
	    _x_to_y_ratio = _angle / 90;
	};
	if (90 <= _angle && _angle < 180) then {
	    _x_to_y_ratio = 1 - ((_angle - 90) / 90);
	    _y_offset_direction = -1;
	};
	if (180 <= _angle && _angle < 270) then {
	    _x_to_y_ratio = (_angle - 180) / 90;
	    _x_offset_direction = -1;
	    _y_offset_direction = -1;
	};
	if (270 <= _angle && _angle < 360) then {
	    _x_to_y_ratio = 1 - ((_angle - 270) / 90);
	    _x_offset_direction = -1;
	};

	// The square of the hypotenuse (distance from origin) equals the sum of the squares
	// of the two legs (x and y offsets)
	_offset_sum_of_squares = _param_distance * _param_distance;
	_x_offset_square = _offset_sum_of_squares * _x_to_y_ratio;
	_y_offset_square = _offset_sum_of_squares - _x_offset_square;

	_x_offset = (sqrt _x_offset_square) * _x_offset_direction;
	_y_offset = (sqrt _y_offset_square) * _y_offset_direction;

	// Apply offset to origin
	_position = [(_param_origin select 0) + _x_offset, (_param_origin select 1) + _y_offset];
	_position;
};

_fnc_uavScan = {
	_param_radius = _this select 0;
	_param_interval = _this select 1;

	_marker_names = [];
	_marker_id_sequence = 0;

	waitUntil {
	    {
	        deleteMarker _x;
	        _marker_names = _marker_names - [_x];
	    } forEach _marker_names;

	    {
	        if (alive _x && side _x == east) then {
	            _marker_name = format ["uav_scan_%1", _marker_id_sequence];
	            _marker_id_sequence = _marker_id_sequence + 1;

	            _marker_position = position _x;
	            
	            _marker = createMarker [_marker_name, _marker_position];
	            _marker_name setMarkerShape "ICON";
	            _marker_name setMarkerType "mil_dot_noshadow";
	            _marker_name setMarkerColor "ColorRed";

	            _marker_names = _marker_names + [_marker_name];
	        };
	    } forEach allUnits;

	    sleep _param_interval;
	    false;
	};
};

// Returns true marker is over water
// _param_marker marker to check
_fnc_isMarkerInWater = {
	_param_marker = _this select 0;

	_marker_pos = getMarkerPos _param_marker;
	_height = getTerrainHeightASL [_marker_pos select 0, _marker_pos select 1];
	(_height <= -1)
};

// Helper method for setting weather values across network
// _param_weather -1 to randomize, or 0-4 for preset values
// _param_time time of day in hours
_fnc_setWeather = {
	_param_weather = _this select 0;
	_param_time = _this select 1;

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
		// Preset values for clear, partly cloudly, cloudy, raining and thunderstorm
		_overcast = [0.25, 0.5, 0.75, 0.85, 0.9] select _param_weather;
		_rain     = [0.0,  0.0, 0.0,  0.67, 0.9] select _param_weather;
	};

	// Fog only appears between dusk and dawn
	_fog = if ((22 < _param_time) or (_param_time < 5)) then {
		0.1 + (random 0.6);
	} else {
		0.0;
	};

	[_overcast] call BIS_fnc_setOvercast;
	[_fog, _fog, 0] call BIS_fnc_setFog;

	_fnc_setRain = compile (format ["86400 setRain %1", _rain]);
	[_fnc_setRain, "BIS_fnc_spawn", true, true] call BIS_fnc_MP;

	forceWeatherChange;
};

// Returns a random location on the map.
_fnc_randomizeEnemyLocation = {
	_locations = [];
	waitUntil {
		// Sample a random point
		_random_position = [random 25000, random 25000];

		// Get all viable locations within 1km
		_locations = nearestLocations [_random_position, ["NameCity", "NameVillage", "NameLocal"], 1000];

		// Ensure at least one location was found
		count _locations > 0;
	};
	// Return a random location
	_locations call BIS_fnc_selectRandom;
};

// Returns a random position 500 meters away from the provided position.
// _param_enemy_position position to base returned position on.
_fnc_randomizePlayerPosition = {
	_param_enemy_position = _this select 0;

	_x_offset = random 500;
	_y_offset = 500 - _x_offset;
	if (random 1 > 0.5) then {_x_offset = _x_offset * -1};
	if (random 1 > 0.5) then {_y_offset = _y_offset * -1};

	_random_position = [
		(_param_enemy_position select 0) + _x_offset,
		(_param_enemy_position select 1) + _y_offset
	];

	_random_position;
};

// wrapper function for Tango Hunt script
// _param_area_marker marker where enemies will spawn
// _param_enemy_faction enemies from this faction will spawn
// _param_enemy_strength minimum number of enemies to spawn
_fnc_tangoHunt = {
	_param_area_marker = _this select 0;
	_param_enemy_side = _this select 1;
	_param_enemy_faction = _this select 2;
	_param_enemy_strength = _this select 3;
	_param_player_side = _this select 4;

	// Initialize the mission
	_all_enemies_array = [_area_marker, east, _enemy_faction, _enemy_strength] call compile preprocessFileLineNumbers "tangohunt.sqf";
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

// Server-side initialization
// all parameters are from description.ext
_fnc_serverInit = {
	if (isServer) then {
		// Parameters from description.ext
		_param_enemy_faction = ["Enemy Faction", 0] call BIS_fnc_getParamValue;
		_param_enemy_strength = ["Enemy Scaling", 1] call BIS_fnc_getParamValue;
		_param_time = ["Time of Day", _RANDOMIZE] call BIS_fnc_getParamValue;
		_param_moon_phase = ["Phase of Moon", _RANDOMIZE] call BIS_fnc_getParamValue;
		_param_weather = ["Weather Conditions", _RANDOMIZE] call BIS_fnc_getParamValue;


		// Set number of days to skip to force a certain moon phase
        // Values are days in July 2035 with each moon phase
		_day = if (_param_moon_phase == _RANDOMIZE) then {
			[5, 9, 12, 15, 20] call BIS_fnc_selectRandom;
		} else {
			[5, 9, 12, 15, 20] select _param_moon_phase;
		};

		// Set numbers of hours to skip to force a certain time of day
		_time = if (_param_time == _RANDOMIZE) then {
			random 24;
		} else {
			_param_time;
		};

		// Set weather values
		[_param_weather, _time] call _fnc_setWeather;
		[(24 * _day) + _time, true, false] call BIS_fnc_setDate;

		// Random area selection
		_area_location = [] call _fnc_randomizeEnemyLocation;
		_area_marker = createMarker ["enemy_area", [position _area_location select 0, position _area_location select 1]];
		_area_marker setMarkerSize (size _area_location);

		// Create objective marker and set symbology
		createMarker ["task_marker", (getMarkerPos _area_marker)];
		"task_marker" setMarkerShape "ICON";
		"task_marker" setMarkerType "mil_objective";
		"task_marker" setMarkerColor "ColorRed";

		// Create insertion marker and set symbology
		_insertion_marker_position = [getMarkerPos _area_marker] call _fnc_randomizePlayerPosition;
		_insertion_marker = createMarker ["player_start", _insertion_marker_position];
		_insertion_marker setMarkerShape "ICON";
		_insertion_marker setMarkerType "mil_start";
		_insertion_marker setMarkerColor "ColorBlue";

		// Set the spawn location
		"respawn_west" setMarkerPos (getMarkerPos _insertion_marker);

		// Enemy faction lookup
		_enemy_faction = ["CSAT", "AAF", "FIA"] select _param_enemy_faction;

		// Get all playable units for enemy strength auto-balance
		// We have to check dead units as well since players start out in the respawn menu
		_all_players_array = playableUnits;
		{
			if (isPlayer _x) then {
				_all_players_array = _all_players_array + [_x];
			};
		} forEach allDeadMen;
		_player_count = count _all_players_array;

		_enemy_strength = [_player_count, (ceil (_player_count * 1.5)), (_player_count * 2)] select _param_enemy_strength;

		[_area_marker, east, _enemy_faction, _enemy_strength, west] call _fnc_tangoHunt;

		// Export variables used for client-local commands
		["mission_area_marker", _area_marker] call _fnc_exportToPublicMissionNamespace;

		// Set flag for clients to continue
		["mission_tangohunt_init", true] call _fnc_exportToPublicMissionNamespace;

		true;
	} else {
		false;
	};
};

_fnc_main = {
	_param_uav_radius = 20;
	_param_uav_interval = 5;

	// Stop immediately if running in singleplayer
	if (!isMultiplayer) exitWith {
		["SinglePlayer", false, 0] spawn BIS_fnc_endMission;
	};

	// Flag that indicates when server init is complete
	missionNamespace setVariable ["mission_tangohunt_init", false];

	// Perform server side init
	if (isServer) then {
		[] call _fnc_serverInit;
		// Start UAV scan on new thread
		[_param_uav_radius, _param_uav_interval] spawn _fnc_uavScan;
	};

	// Process briefing
	execVM "briefing.sqf";

	// Wait for server to finish
	waitUntil {missionNamespace getVariable "mission_tangohunt_init";};

	// Add loadouts from description.ext
	if (["respawn_west"] call _fnc_isMarkerInWater) then {
		[west, "NatoDiver"              ] call BIS_fnc_addRespawnInventory;
	} else {
		[west, "NatoGrenadier"          ] call BIS_fnc_addRespawnInventory;
		[west, "NatoAutomaticRifleman"  ] call BIS_fnc_addRespawnInventory;
		[west, "NatoDesignatedMarksman" ] call BIS_fnc_addRespawnInventory;
		[west, "NatoAntiarmor"          ] call BIS_fnc_addRespawnInventory;
		[west, "NatoMedic"              ] call BIS_fnc_addRespawnInventory;
		[west, "NatoRecon"              ] call BIS_fnc_addRespawnInventory;
		[west, "NatoExplosive"          ] call BIS_fnc_addRespawnInventory;
	};

	// Retreive variables calculated on the server
	_area_marker      = missionNamespace getVariable "mission_area_marker";

	// Create task for objective
	[player, "task_objective", [
		"Attack the enemy infantry force and secure the area marked on the map.",
		"Secure the area",
		_area_marker
	], objNull, true] call BIS_fnc_taskCreate;

	["TaskAssigned", ["Secure area"]] call BIS_fnc_showNotification;
};

[] call _fnc_main;