fnc_startHarassment = {
    params ["_zoneCenter", "_zoneWidth", "_zoneHeight"];

    private _interval = 25;
    private _harassTypes = ["infantry", "mortar", "patrol"];
    private _lastHarassTime = time;

    while {true} do {
        if (missionNamespace getVariable ["ZoneActive", false]) then {
            private _elapsed = time - _lastHarassTime;

            if (_elapsed >= _interval) then {
                private _harassType = selectRandom _harassTypes;
                private _unitCount = floor random [2, 3, 4];

                switch (_harassType) do {
                    case "infantry": {
                        private _spawnPos = [_zoneCenter, _zoneWidth, _zoneHeight, 350] call (missionNamespace getVariable "fnc_getOutsideZonePos");
                        [_unitCount, _spawnPos, _zoneCenter, _zoneWidth, _zoneHeight] spawn (missionNamespace getVariable "fnc_spawn_troops");
                    };
                    case "mortar": {
                        private _mortarUnits = missionNamespace getVariable ["Active_mortarUnits", []];
                        private _validMortars = _mortarUnits select { !isNull _x && {alive _x} };

                        if (count _validMortars > 0) then {
                            {
                                [_x, "", 5, 6, 90, _zoneCenter, _zoneWidth, _zoneHeight] spawn (missionNamespace getVariable "fnc_fire_mortar_atPlayer");
                            } forEach _validMortars;
			};
                    };
                    case "patrol": {
                        private _spawnPos = [_zoneCenter, _zoneWidth, _zoneHeight, 375] call (missionNamespace getVariable "fnc_getOutsideZonePos");
                        [_unitCount, _spawnPos, _zoneCenter, _zoneWidth, _zoneHeight] spawn (missionNamespace getVariable "fnc_spawn_troops");
                    };
                };

                _lastHarassTime = time;
            };
        };

        sleep 10;
    };
};

missionNamespace setVariable ["fnc_startHarassment", fnc_startHarassment];

fnc_startCounterattack = {
    params ["_zoneCenter", "_zoneWidth", "_zoneHeight"];

    private _interval = 90;
    private _attackTypes = ["infantry", "humanwave"];
    private _lastAttackTime = time;

    while {true} do {
        if (missionNamespace getVariable ["ZoneActive", false]) then {
            private _elapsed = time - _lastAttackTime;

            if (_elapsed >= _interval) then {
                private _attackType = selectRandom _attackTypes;
                private _unitCount = switch (_attackType) do {
                    case "infantry": { floor random [4, 6, 8] };
                    case "humanwave": { floor random [10, 12, 15] };
                };

                private _spawnPos = [_zoneCenter, _zoneWidth, _zoneHeight, 400] call (missionNamespace getVariable "fnc_getOutsideZonePos");
                [_unitCount, _spawnPos, _zoneCenter, _zoneWidth, _zoneHeight] spawn (missionNamespace getVariable "fnc_spawn_CAtroops");
                _lastAttackTime = time;
            };
        };

        sleep 10;
    };
};

missionNamespace setVariable ["fnc_startCounterattack", fnc_startCounterattack];