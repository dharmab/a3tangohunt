/*
@return (position2d) A random position on the map that is on land.
*/
_random_position = [0, 0];
_map_size = [] call BIS_fnc_mapSize;
waitUntil {
	_random_position = [random _map_size, random _map_size];
	!([_random_position] call TH_fnc_isPositionInWater);
};
_random_position;
