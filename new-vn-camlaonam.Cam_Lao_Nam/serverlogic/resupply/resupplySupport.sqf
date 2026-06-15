fnc_shutdownStation = {
    params ["_terminal", "_caller"];
    if (!isServer || isNull _terminal) exitWith {};

    {
        if (!isNull _x) then { deleteVehicle _x };
    } forEach (_terminal getVariable ["trackedBuildObjects", []]);

    {
        if (!isNull _x) then { deleteVehicle _x };
    } forEach (_terminal getVariable ["stationObjects", []]);

    private _labelMarker = _terminal getVariable ["stationMarker", ""];
    private _areaMarker  = _terminal getVariable ["stationAreaMarker", ""];

    if (_labelMarker != "") then { deleteMarker _labelMarker };
    if (_areaMarker  != "") then { deleteMarker _areaMarker };

    _terminal setVariable ["supportZones", nil, true];
    _terminal setVariable ["supportLoopActive", nil];

    private _crateModule = missionNamespace getVariable ["crateModuleObject", objNull];
    if (!isNull _crateModule) then {
        deleteVehicle _crateModule;
        missionNamespace setVariable ["crateModuleObject", objNull];
        publicVariable "crateModuleObject";
    };

    missionNamespace setVariable ["sandbagTerminal_1", objNull];
    missionNamespace setVariable ["activeRadioStation", objNull];
    publicVariable "sandbagTerminal_1";
    publicVariable "activeRadioStation";

    missionNamespace setVariable ["sandbagZoneCount", 0];
    publicVariable "sandbagZoneCount";

    if (isPlayer _caller) then {
        private _name = format ["Closed by: %1", name _caller];
        ["StationShutdown", [_name]] remoteExec ["BIS_fnc_showNotification", 0];
    } else {
        private _name = format ["Sabotaged by: %1", name _caller];
        ["StationDestroyed", [_name]] remoteExec ["BIS_fnc_showNotification", 0];
    };
};

missionNamespace setVariable ["fnc_shutdownStation", fnc_shutdownStation];