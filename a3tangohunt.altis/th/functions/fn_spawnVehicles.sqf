/*
Spawn empty vehicles near a given position.
@param _param_faction (string) name of faction template determining which vehicles will spawn
@param _param_position (position2d) position near which vehicles will spawn
@param _param_direction (number) direction vehicles will face
@param _param_number_of_cars (number) number of cars that will spawn. If no car class is found in the faction template,
FIA technicals ("B_G_Offroad_01_armed_F") will be spawned.
@param _param_number_of_apcs (number) number of APCs that will spawn. If no APC class is found in the faction template,
additional cars will be spawned instead.
@param _param_number_of_tanks (number) number of tanks that will spawn. If no tank class is found in the faction template,
additional APCs or cars will be spawned instead.
*/
_param_faction   = _this select 0;
_param_position  = _this select 1;
_param_direction = _this select 2;
_param_number_of_cars = _this select 3;
_param_number_of_apcs = _this select 4;
_param_number_of_tanks = _this select 5;

_car_class  = "";
_apc_class  = "";
_tank_class = "";

// Load classnames from faction template
_faction_template = [_param_faction] call TH_fnc_getFactionTemplate;

{
    _key = _x select 0;
    _value = _x select 1;

    switch (_key) do {
        case "car": {
            _car_class = _value;
        };
        case "apc": {
            _apc_class = _value;
        };
        case "tank": {
            _tank_class = _value;
        };
    };
} forEach _faction_template;

/*
Spawn empty vehicles of a given class
@param _param_vehicle_class (classname) classname of vehicle to spawn
@param _param_number_of_vehicles (number) number of vehicles to spawn
@param _param_position (position2d) position near which vehicle will spawn
@param _param_direction (number) direction vehicle will face
*/
_fnc_spawnVehicles = {
    _param_vehicle_class      = _this select 0;
    _param_number_of_vehicles = _this select 1;
    _param_position           = _this select 2;
    _param_direction          = _this select 3;

    for [{_i = 0}, {_i < _param_number_of_vehicles}, {_i = _i + 1}] do {
        _new_vehicle_position = [_param_position, 25, 50, 15, 0, 100, 0] call BIS_fnc_findSafePos;
        _new_vehicle = _param_vehicle_class createVehicle _new_vehicle_position;
        _new_vehicle setDir _param_direction;
    };
};

if (_tank_class != "") then {
    [_tank_class, _param_number_of_tanks, _param_position, _param_direction] call _fnc_spawnVehicles;
} else {
    _param_number_of_apcs = _param_number_of_apcs + _param_number_of_tanks;
    logger_logic globalChat "The player faction doesn't have any tanks. Spawning APCs instead.";
};

if (_apc_class != "") then {
    [_apc_class, _param_number_of_apcs, _param_position, _param_direction] call _fnc_spawnVehicles;
} else {
    _param_number_of_cars = _param_number_of_cars + _param_number_of_apcs;
    logger_logic globalChat "The player faction doesn't have any APCs. Spawning light vehicles instead.";
};

if (_car_class == "") then {
    _car_class == "B_G_Offroad_01_armed_F";
};

[_car_class, _param_number_of_cars, _param_position, _param_direction] call _fnc_spawnVehicles;
true;