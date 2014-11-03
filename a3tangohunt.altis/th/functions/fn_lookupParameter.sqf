_param_lookup_table = _this select 0;
_param_parameter_value = _this select 1;

// Value indicating that a parameter from description.ext should be randomized
_RANDOMIZE = -1;

if (_param_parameter_value == _RANDOMIZE) then {
    _param_lookup_table call BIS_fnc_selectRandom;
} else {
    _param_lookup_table select _param_parameter_value;
};