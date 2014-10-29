// Returns true if position is over water
// _param_position position to check
_param_position = _this select 0;

_height = getTerrainHeightASL _param_position;
_height <= -1