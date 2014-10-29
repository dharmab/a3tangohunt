_param_origin = _this select 0;
_param_distance = _this select 1;
_param_angle = _this select 2;

// Sanitize angle
_angle = _param_angle % 360;
if (_angle < 0) then {
	_angle = 360 + _angle;
};

// use the quadrant and angle to determine ratio and sign of x and y offsets
_x_offset_direction = 1;
_y_offset_direction = 1;
_x_to_y_ratio = 0.0;
if (0 <= _angle && _angle < 90) then {
	_x_to_y_ratio = _angle / 90;
};
if (90 <= _angle && _angle < 180) then {
	_x_to_y_ratio = 1 - ((_angle - 90) / 90);
	_y_offset_direction = -1;
};
if (180 <= _angle && _angle < 270) then {
	_x_to_y_ratio = (_angle - 180) / 90;
	_x_offset_direction = -1;
	_y_offset_direction = -1;
};
if (270 <= _angle && _angle < 360) then {
	_x_to_y_ratio = 1 - ((_angle - 270) / 90);
	_x_offset_direction = -1;
};

// The square of the hypotenuse (distance from origin) equals the sum of the squares
// of the two legs (x and y offsets)
_offset_sum_of_squares = _param_distance * _param_distance;
_x_offset_square = _offset_sum_of_squares * _x_to_y_ratio;
_y_offset_square = _offset_sum_of_squares - _x_offset_square;

_x_offset = (sqrt _x_offset_square) * _x_offset_direction;
_y_offset = (sqrt _y_offset_square) * _y_offset_direction;

// Apply offset to origin
_position = [(_param_origin select 0) + _x_offset, (_param_origin select 1) + _y_offset];
_position;