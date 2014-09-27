_player_side = _this select 0;

fnc_areAllPlayersDead = {
	_result = true;
	{
		if ((side _x == _player_side) && alive _x) then {
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
  sleep 1;
  _is_defeat = [] call fnc_areAllPlayersDead;
  _is_defeat;
};

["loser", false, 0] spawn BIS_fnc_endMission;
