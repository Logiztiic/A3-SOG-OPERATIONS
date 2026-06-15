fnc_monitorVehicleRespawns = {
    [] spawn {
        private _tracked = missionNamespace getVariable ["trackedVehicles", []];

        while {true} do {
            private _timeNow = time;

            {
                private _entry = _x;
                private _veh   = _entry select 0;

                if (!isNull _veh && !alive _veh) then {
                    private _deathTime = _entry select 5;
                    private _respawnDelay = _entry select 4;

                    if (_deathTime < 0) then {
                        _entry set [5, _timeNow];
                    } else {
                        if ((_timeNow - _deathTime) >= _respawnDelay) then {
                            [_entry] call (missionNamespace getVariable "fnc_respawnVehicle");
                        };
                    };
                };
            } forEach _tracked;

            sleep 5;
        };
    };
};

missionNamespace setVariable ["fnc_monitorVehicleRespawns", fnc_monitorVehicleRespawns];