/*
Check if a position is in water.
The builtin surfaceIsWater command does not work with inland lakes or ponds, while this function will work with any
water at or below sea level.
@return (boolean) true if the location is in water deeper than 1 meter. False otherwise.
*/
_param_position = _this select 0;

_height = getTerrainHeightASL _param_position;
_height <= -1