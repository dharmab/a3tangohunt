_param_source_position = _this select 0;
_param_destination_position = _this select 1;

_x_delta = (_param_destination_position select 0) - (_param_source_position select 0);
_y_delta = (_param_destination_position select 1) - (_param_source_position select 1);

// A little help from our friend Chief Sohcahtoa...
 _x_delta atan2 _y_delta;
