_param_origin = _this select 0;
_param_distance = _this select 1;
_param_angle = _this select 2;

_x_offset = cos _param_angle * _param_distance;
_y_offset = sin _param_angle * _param_distance;
_position = [(_param_origin select 0) + _x_offset, (_param_origin select 1) + _y_offset];
_position;