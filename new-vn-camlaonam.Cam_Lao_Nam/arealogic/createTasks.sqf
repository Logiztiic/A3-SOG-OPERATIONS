fnc_createTask = {
    params ["_taskID", "_title", "_description", "_position", "_type"];

    if (isServer) then {
        [
            true,
            _taskID,                    
            [_description, _title, ""],
            _position,                   
            "CREATED",                   
            -1,                         
            false,                       
            _type                        
        ] call BIS_fnc_taskCreate;
    };
};

fnc_completeTask = {
    params ["_taskID"];

    if (isServer) then {
        [_taskID, "SUCCEEDED", false] call BIS_fnc_taskSetState;
    };
};

fnc_startTaskSequence = {
    params ["_center", "_width", "_height"];

    if (!isServer) exitWith {};

    private _basePos = _center;

    private _taskPool = [
        ["task_destroySites", "Destroy Sites", "Find and destroy all enemy mortar/AA sites in the area.", _basePos vectorAdd [25, -25, 0], "Destroy"],
        ["task_findIntel", "Locate Intel", "Search the area for enemy intel stations and recover documents.", _basePos vectorAdd [-30, 20, 0], "Search"],
        ["task_holdArea", "Hold the Area", "Hold the area against enemy counterattacks.", _basePos vectorAdd [0, 40, 0], "Defend"]
    ];

    private _first = _taskPool select 0;   // destroy sites
    private _second = _taskPool select 1;  // find intel
    private _final = _taskPool select 2;   // hold area

    [_first select 0, _first select 1, _first select 2, _first select 3, _first select 4] call fnc_createTask;
    [_second select 0, _second select 1, _second select 2, _second select 3, _second select 4] call fnc_createTask;

    missionNamespace setVariable ["ActiveTasks", [_first select 0, _second select 0]];

    [_center, _width, _height, _final] spawn {
        params ["_center", "_width", "_height", "_final"];

        waitUntil {
            (["task_destroySites", true] call BIS_fnc_taskState == "SUCCEEDED") &&
            (["task_findIntel", true] call BIS_fnc_taskState == "SUCCEEDED")
        };

        [_final select 0, _final select 1, _final select 2, _final select 3, _final select 4] call fnc_createTask;

        [_center, _width, _height, _final select 0, 10] call (missionNamespace getVariable "fnc_monitorDefendZone"); //1750

        terminate (missionNamespace getVariable ["CounterattackThread", scriptNull]);
        missionNamespace setVariable ["CounterattackThread", nil];

        private _counterattackThread = [_center, _width, _height] spawn (missionNamespace getVariable "fnc_startCounterattack");
        missionNamespace setVariable ["CounterattackThread", _counterattackThread];
    };
};

missionNamespace setVariable ["fnc_completeTask", fnc_completeTask];
missionNamespace setVariable ["fnc_startTaskSequence", fnc_startTaskSequence];
