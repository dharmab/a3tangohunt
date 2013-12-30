"task_objective" setTaskState "Failed";
["TaskFailed", ["Secure the Area"]] call BIS_fnc_showNotification;
sleep 15;
["Defeat", false, true] call BIS_fnc_endMission;