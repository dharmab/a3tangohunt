/*
Utility function for loading values from tables, e.g. mission parameters.
@param _param_lookup_table (array) table to use in lookup.
@param _param_selection (number) if -1, a random value will be chosen from the table. Otherwise,
the item with the same index will be chosen.
@return the chosen value from the table
*/
_param_lookup_table = _this select 0;
_param_selection = _this select 1;

// Value indicating that a parameter from description.ext should be randomized
_RANDOMIZE = -1;

if (_param_selection == _RANDOMIZE) then {
	_param_lookup_table call BIS_fnc_selectRandom;
} else {
	_param_lookup_table select _param_selection;
};
