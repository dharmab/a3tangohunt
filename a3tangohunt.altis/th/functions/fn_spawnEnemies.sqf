_param_area_marker           = _this select 0; // Marker where enemies will be spawned
_param_side                  = _this select 1; // Side that units will spawn on. (west, east, resistance)
_param_faction_template_name = _this select 2; // Faction template name e.g. "a3_nato"
_param_default_behavior      = _this select 3; // default combat mode, "CARELESS", "SAFE", "AWARE", "COMBAT", "STEALTH"
_param_number_of_infantry    = _this select 4; // number of  infantry to spawn, integer > 0
_param_number_of_cars        = _this select 5; // number of  cars to spawn, integer >= 0
_param_number_of_apcs        = _this select 6; // number of  APCs to spawn, integer >= 0
_param_number_of_tanks       = _this select 7; // number of  tanks to spawn, integer >= 0

// Spawn vehicles which will randomly either patrol or defend an area
_fnc_spawnVehicles = {
	_param_vehicle_class      = _this select 0; // Classname of vehicle to spawn
	_param_vehicle_side       = _this select 1; // Side on which vehicle will be spawned
	_param_number_of_vehicles = _this select 2; // Number of vehicles to spawn
	_param_area_position      = _this select 3; // Position near which vehicles will spawn
	_param_patrol_probability = _this select 4; // Probability vehicle will patrol the area instead of defending (0.0-1.0)

	_n = 0;
	_crew = [];
	while {_n < _param_number_of_vehicles} do {
		_new_vehicle_position = [_param_area_position, 25, 250, 50, 0, 20, 0] call BIS_fnc_findSafePos;
		_return = [_new_vehicle_position, random 360, _param_vehicle_class, _param_vehicle_side] call BIS_fnc_spawnVehicle;
		_new_vehicle = _return select 0;
		_new_vehicle_crew = _return select 1;
		_new_vehicle_group = createGroup _param_vehicle_side;
		_new_vehicle_crew joinSilent _new_vehicle_group;

		if (random 1 < _param_patrol_probability) then {
			[_new_vehicle_group, getPos _new_vehicle, 250] call BIS_fnc_taskPatrol;
		} else {
			[_new_vehicle_group, getPos _new_vehicle] call BIS_fnc_taskDefend;
		};

		_n = _n + 1;
		_crew = _crew + _new_vehicle_crew;
	};
	_crew;
};

_ai_team_leader   = "";
_ai_rifleman      = "";
_ai_machinegunner = "";
_ai_marksman      = "";
_ai_antitank      = "";

_ai_car_unarmed   = "";
_ai_car           = "";
_ai_apc           = "";
_ai_tank          = "";

// Load classnames from faction template
_faction_template = [_param_faction_template_name] call TH_fnc_getFactionTemplate;

{
	_key = _x select 0;
	_value = _x select 1;

	switch (_key) do {
		case "team_leader": {
			_ai_team_leader = _value;
		};
		case "rifleman": {
			_ai_rifleman = _value;
		};
		case "machine_gunner": {
			_ai_machinegunner = _value;
		};
		case "designated_marksman": {
			_ai_marksman = _value;
		};
		case "antiarmor_specialist": {
			_ai_antitank = _value;
		};
		case "car": {
			_ai_car = _value;
		};
		case "apc": {
			_ai_apc = _value;
		};
		case "tank": {
			_ai_tank = _value;
		};
	};
} forEach _faction_template;

// Possibilities for number of AI spawned in a group
_spawned_group_size_distribution = if (_param_number_of_infantry <= 5) then {
	[1, 2, 2, 3];
} else {
	[1, 2, 2, 3, 4, 4, 4, 4, 5, 6];
};
// Possibilities for class of AI spawned in a group; Groups above a certain size always have a team leader
_spawned_unit_type_distribution = [_ai_rifleman, _ai_rifleman, _ai_rifleman, _ai_rifleman, _ai_machinegunner, _ai_machinegunner, _ai_marksman, _ai_antitank]; 

_area_marker_position = getMarkerPos _param_area_marker;
_area_marker_size = ((getMarkerSize _param_area_marker select 0) + (getMarkerSize _param_area_marker select 1)) / 2.0;

_spawned_units = [];

// Spawn tanks
if (_ai_tank != "") then {
	_spawned_units = _spawned_units + ([_ai_tank, _param_side, _param_number_of_tanks, _area_marker_position, 0.25] call _fnc_spawnVehicles);
} else {
	_param_number_of_apcs = _param_number_of_apcs + (_param_number_of_tanks * 2);
	logger_logic globalChat "The enemy faction doesn't have any tanks. Additional enemy APCs have been added instead.";
};

// Spawn APCs
if (_ai_apc != "") then {
	_spawned_units = _spawned_units + ([_ai_apc, _param_side, _param_number_of_apcs, _area_marker_position, 0.50] call _fnc_spawnVehicles);
} else {
	_param_number_of_cars = _param_number_of_cars + (_param_number_of_apcs * 2);
	logger_logic globalChat "The enemy faction doesn't have any APCs. Additional enemy light vehicles have been added instead.";
};

// Spawn cars
if (_ai_car != "") then {
	_spawned_units = _spawned_units + ([_ai_car, _param_side, _param_number_of_cars, _area_marker_position, 0.75] call _fnc_spawnVehicles);
} else {
	_param_number_of_infantry = _param_number_of_infantry + (_param_number_of_cars * 2);
	logger_logic globalChat "The enemy faction doesn't have any light vehicles. Additional enemy infantry have been added instead.";
};

// Spawn infantry units and set them to patrol the area
_spawned_infantry_count = 0;
while {_spawned_infantry_count < _param_number_of_infantry} do {
	_ai_count_group_total = _spawned_group_size_distribution call BIS_fnc_selectRandom;

	_new_group = createGroup _param_side;
	_new_group_position = [_area_marker_position, 25, 150, 1, 0, 100, 0] call BIS_fnc_findSafePos;

	// Groups with 4 or more members have a team leader
	if (_ai_count_group_total >= 4) then {
		_ai_team_leader createUnit [_new_group_position, _new_group];
	};
	
	while {(count (units _new_group)) < _ai_count_group_total} do {
		(_spawned_unit_type_distribution call BIS_fnc_selectRandom) createUnit [_new_group_position, _new_group];
	};

	// Add several patrol waypoints and a final defend waypoint to the new group
	[_new_group, getPos leader _new_group, 250] call BIS_fnc_taskPatrol;
	_defend_waypoint = _new_group addWaypoint [_area_marker_position, _area_marker_size];
	_defend_waypoint setWaypointType "MOVE";
	_defend_waypoint setWaypointStatements ["true", "nul = [group this, position this] call BIS_fnc_taskDefend;"];

	_new_group setBehaviour _param_default_behavior;
	
	_spawned_infantry_count = _spawned_infantry_count + (count units _new_group);
	_spawned_units = _spawned_units + units _new_group;
};

_spawned_units;
