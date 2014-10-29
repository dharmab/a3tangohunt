_param_item = _this select 0;
_param_quantity = _this select 1;
_param_inventory = _this select 2;

if (_param_item == "") exitWith {};
if (_param_quantity <= 0) exitWith {};

_fnc_addItemCode = {};
switch (_param_inventory) do {
	case "uniform":
	{
		_fnc_addItemCode = {player addItemToUniform _param_item};
	};
	case "vest":
	{
		_fnc_addItemCode = {player addItemToVest _param_item};
	};
	case "backpack":
	{
		_fnc_addItemCode = {player addItemToBackpack _param_item};
	};
	default
	{
		// do nothing
	};
};

for "_i" from 1 to _param_quantity do _fnc_addItemCode;