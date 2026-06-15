fnc_createSupportZone = {
    params ["_pos", "_type", "_terminal"];
    if (!isServer || isNull _terminal) exitWith {};

    private _radius = switch (_type) do {
        case "rearm": { 25 };
        case "repair": { 25 };
        default { 0 };
    };

    if (_radius <= 0) exitWith {
        diag_log format ["[SupportZone] Invalid type: %1", _type];
    };

    private _zones = _terminal getVariable ["supportZones", []];
    _zones pushBack [_pos, _type, _radius];
    _terminal setVariable ["supportZones", _zones, true];

    if (isNil {_terminal getVariable "supportLoopActive"}) then {
        _terminal setVariable ["supportLoopActive", true];

        [_terminal] spawn {
            params ["_terminal"];
            while { !isNull _terminal } do {
                private _zones = _terminal getVariable ["supportZones", []];

                {
                    private _pos = _x select 0;
                    private _type = _x select 1;
                    private _radius = _x select 2;

                    private _nearby = _pos nearEntities [["LandVehicle", "Air"], _radius];
                    {
                        private _driver = driver _x;
                        if (isPlayer _driver) then {
                            switch (_type) do {
                                case "rearm": {
                                    [_driver] remoteExec ["fnc_applyRearmEffect", _driver];
                                };
                                case "repair": {
                                    [_driver] remoteExec ["fnc_applyRepairEffect", _driver];
                                };
                            };
                        };
                    } forEach _nearby;
                } forEach _zones;

                sleep 10;
            };
        };
    };
};

missionNamespace setVariable ["fnc_createSupportZone", fnc_createSupportZone];

fnc_applyRearmEffect = {
    params ["_unit"];
    private _veh = vehicle _unit;
    if (!local _veh || !alive _veh) exitWith {};
    _veh setVehicleAmmo 1;
};

missionNamespace setVariable ["fnc_applyRearmEffect", fnc_applyRearmEffect];


fnc_applyRepairEffect = {
    params ["_unit"];
    private _veh = vehicle _unit;
    if (!local _veh || !alive _veh) exitWith {};
    _veh setDamage 0;
};

missionNamespace setVariable ["fnc_applyRepairEffect", fnc_applyRepairEffect];
