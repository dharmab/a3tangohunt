_player_side = _this select 0;
_enemies_array = _this select 1;
_area_marker = _this select 2;
_dead_threshold = _this select 3;

fnc_isInMarker = {
	_param_unit = _this select 0;
	_param_marker = _this select 1;

	_marker_size_array = getMarkerSize _param_area_marker;
	_marker_radius = (_marker_size_array select 0) max (_marker_size_array select 1);

	(_x distance (getMarkerPos _param_area_marker)) < _marker_radius;
};

fnc_isPlayerVictory = {
	_param_enemies_array = _this select 0;
	_param_area_marker = _this select 1;
	_param_dead_threshold = _this select 2;


	// Count number of enemies who are dead or not in the area
	_dead = 0;
	{
		_is_unit_in_marker = [_x, _param_area_marker] call fnc_isInMarker;
		if ((!alive _x) || !_is_unit_in_marker) then {
			_dead = _dead + 1;
		}
	} forEach _param_enemies_array;

	// Determine if remaining enemy count is low enough to declare victory
	_result = false;
	if ((_dead / (count _param_enemies_array)) >= _param_dead_threshold) then {
		_result = true;
	};
	_result;
};

fnc_areAllPlayersDead = {
	_result = true;
	{
		if ((side _x == west) && alive _x) then {
			_result = false;
		}
	} forEach allUnits;
	_result;
};

_is_victory = false;
_is_defeat = false;

// silly way to wait until least one player is alive
waitUntil {
  sleep 1;
  !([_player_side] call fnc_areAllPlayersDead);
};

// wait until either all players are dead or enough enemies have been defeated
waitUntil {
  sleep round (15 + (random 45));
  _is_victory = [_enemies_array, _area_marker, _dead_threshold] call fnc_isPlayerVictory;
  _is_defeat = [] call fnc_areAllPlayersDead;
  _is_defeat or _is_victory;
};

if (_is_defeat) then {
	["loser", false, 0] spawn BIS_fnc_endMission;
} else {
	["Victory", false, 0] spawn BIS_fnc_endMission;
};
