fnc_preventZoneHang = {
    if (!isServer) exitWith {
        diag_log "fnc_preventZoneHang: Called on client — exiting.";
    };

    private _zoneID = missionNamespace getVariable ["ActiveZoneID", ""];
    private _zoneStartTime = missionNamespace getVariable ["ActiveZone_startTime", -1];

    private _taskSites = "task_destroySites";
    private _taskIntel = "task_findIntel";

    if (_zoneID isEqualTo "" || {_zoneStartTime < 0}) exitWith {
        diag_log "fnc_preventZoneHang: No active zone or missing start time — aborting.";
    };

    private _elapsed = time - _zoneStartTime;
    private _sitesState = [_taskSites] call BIS_fnc_taskState;
    private _intelState = [_taskIntel] call BIS_fnc_taskState;

    // 4200 seconds = 70 minutes
    if (_elapsed > 4200 && {_intelState == "SUCCEEDED"} && {_sitesState != "SUCCEEDED"}) then {

        diag_log format [
            "[IntelHang] Zone %1 exceeded 70 minutes with Sites completed but Intel incomplete. Auto-completing intel task.",
            _zoneID
        ];

        // Complete all active tasks (destroy + intel)
        private _allTasks = missionNamespace getVariable ["ActiveTasks", []];
        {
            [_x] call (missionNamespace getVariable "fnc_completeTask");
        } forEach _allTasks;

        diag_log format [
            "fnc_preventZoneHang: Auto-completed %1 tasks. Proceeding to zone completion.",
            count _allTasks
        ];
    };
};

missionNamespace setVariable ["fnc_preventZoneHang", fnc_preventZoneHang];