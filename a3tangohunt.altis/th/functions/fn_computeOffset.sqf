/*
Determines an offset position from an origin position
@param _param_origin (position2d) origin position
@param _param_distance (number) distance in meters
@param _param_direction (number) direction in degrees
@return (position2d) The position found by traveling the given distance from the origin in the given direction
*/

_param_origin = _this select 0;
_param_distance = _this select 1;
_param_direction = _this select 2;

_x_offset = cos _param_direction * _param_distance;
_y_offset = sin _param_direction * _param_distance;
_position = [(_param_origin select 0) + _x_offset, (_param_origin select 1) + _y_offset];
_position;
