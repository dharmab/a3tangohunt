/*
Populates an area with AI.
@param _param_area_marker (marker) marker where enemies will be spawned
@param _param_side (west, east, resistance) side that units will spawn on
@param _param_faction_template_name (string) name of faction template determining which units will spawn
@param _param_default_behavior ("CARELESS", "SAFE", "AWARE", "COMBAT", "STEALTH")
@param _param_number_of_infantry (number) approximate number of infantry to spawn
@param _param_number_of_cars (number) exact number of cars to spawn
@param _param_number_of_apcs (number) exact number of APCs to spawn
@param _param_number_of_tanks (number) exact number of tanks to spawn
@return (array) all units spawned by this script
*/
_param_area_marker           = _this select 0;
_param_side                  = _this select 1;
_param_faction_template_name = _this select 2;
_param_default_behavior      = _this select 3;
_param_number_of_infantry    = _this select 4;
_param_number_of_cars        = _this select 5;
_param_number_of_apcs        = _this select 6;
_param_number_of_tanks       = _this select 7;

/*
Spawn crewed vehicles which will randomly either patrol or defend an area
@param _param_vehicle_class (classname) Classname of vehicle to spawn
@param _param_vehicle_side (west, east, resistance) Side on which vehicle will be spawned
@param _param_number_of_vehicles (number) Number of vehicles to spawn
@param _param_area_position (number) Position near which vehicles will spawn
@return (array) all crew spawned by this function
*/
_fnc_spawnVehicles = {
	_param_vehicle_class      = _this select 0;
	_param_vehicle_side       = _this select 1;
	_param_number_of_vehicles = _this select 2;
	_param_area_position      = _this select 3;

	_n = 0;
	_crew = [];
	while {_n < _param_number_of_vehicles} do {
		_new_vehicle_position = [_param_area_position, 25, 250, 5, 0, 100, 0] call BIS_fnc_findSafePos;
		_return = [_new_vehicle_position, random 360, _param_vehicle_class, _param_vehicle_side] call BIS_fnc_spawnVehicle;
		_new_vehicle = _return select 0;
		_new_vehicle_crew = _return select 1;
		_new_vehicle_group = createGroup _param_vehicle_side;
		_new_vehicle_crew joinSilent _new_vehicle_group;


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
	_spawned_units append ([_ai_tank, _param_side, _param_number_of_tanks, _area_marker_position] call _fnc_spawnVehicles);
} else {
	if (_param_number_of_tanks > 0) then {
		logger_logic globalChat "The faction doesn't have any tanks. Additional APCs have been added instead.";
	};
	_param_number_of_apcs = _param_number_of_apcs + (_param_number_of_tanks * 2);
};

// Spawn APCs
if (_ai_apc != "") then {
	_spawned_units append ([_ai_apc, _param_side, _param_number_of_apcs, _area_marker_position] call _fnc_spawnVehicles);
} else {
	if (_param_number_of_apcs > 0) then {
		logger_logic globalChat "The faction doesn't have any APCs. Additional light vehicles have been added instead.";
	};
	_param_number_of_cars = _param_number_of_cars + (_param_number_of_apcs * 2);
};

// Spawn cars
if (_ai_car != "") then {
	_spawned_units append ([_ai_car, _param_side, _param_number_of_cars, _area_marker_position] call _fnc_spawnVehicles);
} else {
	if (_param_number_of_cars > 0) then {
		logger_logic globalChat "The faction doesn't have any light vehicles. Additional infantry have been added instead.";
	};
	_param_number_of_infantry = _param_number_of_infantry + (_param_number_of_cars * 2);
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

	_new_group setBehaviour _param_default_behavior;

	_spawned_infantry_count = _spawned_infantry_count + (count units _new_group);
	_spawned_units append units _new_group;
};

_spawned_units;
