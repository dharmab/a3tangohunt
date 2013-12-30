"task_objective" setTaskState "Succeeded";
["TaskSucceeded", ["Secure the Area"]] call BIS_fnc_showNotification;
sleep 15;
["Victory", true, true] call BIS_fnc_endMission;