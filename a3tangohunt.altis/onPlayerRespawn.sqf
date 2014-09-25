_should_spectate = missionNamespace getVariable "spectate_on_death";
if (isNil "_should_spectate") then {
	_should_spectate = false;
};
if (_should_spectate) then {
	call F_fnc_CamInit;
} else {
	missionNamespace setVariable ["spectate_on_death", true];
};
