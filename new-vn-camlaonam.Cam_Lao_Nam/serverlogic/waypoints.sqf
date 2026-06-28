fnc_dynamicWaypointLoop = {
    params ["_enemyGroup", "_area", "_area_a", "_area_b", "_enemyUnit"];

    missionNamespace setVariable ["reconTraitChecked", []];

    private _safezones = [
        [[16311.8, 7101.64, 0], 1500, 1500] // Pleiku Airbase
    ];

    private _isInZoneSet = {
        params ["_unit", "_zones"];
        private _pos = getPosATL _unit;
        {
            private _center = _x select 0;
            private _w = _x select 1;
            private _h = _x select 2;
            if (_pos inArea [_center, _w, _h, 0, false, 0]) exitWith {true};
        } forEach _zones;
        false
    };

    while {true} do {
        private _playerArray = (allPlayers + (allUnits select {side _x == west})) - entities "HeadlessClient_F";

        private _validPlayers = _playerArray select {
            _x inArea [_area, _area_a, _area_b, 0, false, 500] &&
            {!([_x, _safezones] call _isInZoneSet)}
        };

        private _target = objNull;
        private _checkedRecon = missionNamespace getVariable ["reconTraitChecked", []];
        private _reconCheckCap = floor (count _playerArray / 4);

        if (count _validPlayers > 0) then {
            private _filtered = [];

            {
                private _uid = getPlayerUID _x;

                if ((_checkedRecon find _uid) == -1 && {_x getUnitTrait "Recon"}) then {
                    if (count _checkedRecon < _reconCheckCap) then {
                        _checkedRecon pushBack _uid;
                        missionNamespace setVariable ["reconTraitChecked", _checkedRecon];

                        if (random 1 > 0.2) then {
                            _filtered pushBack _x;
                        };
                    } else {
                        _filtered pushBack _x;
                    };
                } else {
                    _filtered pushBack _x;
                };
            } forEach _validPlayers;

            if (count _filtered > 0) then {
                _target = selectRandom _filtered;
            };
        };

        if (isNull _target) then {
            private _aaUnits = missionNamespace getVariable ["Active_aaUnits", []];
            private _mortarUnits = missionNamespace getVariable ["Active_mortarUnits", []];
            private _fallbackUnits = (_aaUnits + _mortarUnits) select {alive _x && {!isNull _x}};

            if (count _fallbackUnits > 0) then {
                _target = selectRandom _fallbackUnits;
            };
        };

        if (isNull _target) then {
            deleteWaypoint [_enemyGroup, 0];
            private _wp_idle = _enemyGroup addWaypoint [getPos _enemyUnit, 0];
            _wp_idle setWaypointType "MOVE";
            _wp_idle setWaypointSpeed "LIMITED";
            _enemyUnit setUnitPos "UP";
            sleep 85;
            continue;
        };

        deleteWaypoint [_enemyGroup, 0];
        private _wp = _enemyGroup addWaypoint [getPos _target, 0];
        _wp setWaypointType "MOVE";

        if (dayTime >= 18 || dayTime <= 5.6) then {
            if (random 1 < 0.6) then {
                _enemyUnit setUnitPos "MIDDLE";
                _wp setWaypointSpeed "FULL";
            } else {
                _enemyUnit setUnitPos "UP";
                _wp setWaypointSpeed "FULL";
            };
        } else {
            _enemyUnit setUnitPos "UP";
            _wp setWaypointSpeed "FULL";
        };

        sleep 85;
    };
};

missionNamespace setVariable ["fnc_dynamicWaypointLoop", fnc_dynamicWaypointLoop];

fnc_handleMeleeBehavior = {
    params ["_unit"];

    if (!isServer || {diag_fps <= 45}) exitWith {
        diag_log format ["[Melee Behavior Skipped] Server FPS too low: %1", diag_fps];
    };

    if (isNil "activeMeleeUnits") then { activeMeleeUnits = []; };
    if (isNil "maxMeleeUnits") then { maxMeleeUnits = 10; };

    private _range = 2.6;

    while {alive _unit} do {
        private _hasAmmo = false;
        {
            if (_unit ammo _x > 0) exitWith { _hasAmmo = true };
        } forEach weapons _unit;

        if (!_hasAmmo) then {
            private _target = objNull;
            private _minDist = 1200;

            {
                if (
                    _x != _unit &&
                    alive _x &&
                    side _x != side _unit
                ) then {
                    private _dist = _unit distance _x;
                    if (_dist < _minDist) then {
                        _minDist = _dist;
                        _target = _x;
                    };
                };
            } forEach allPlayers;

            if (!isNull _target) then {
                _unit setSpeedMode "FULL";
                _unit forceSpeed -1;
                _unit doMove (getPos _target);
                _unit doWatch _target;
                _unit disableAI "AUTOTARGET";
                _unit disableAI "TARGET";
                _unit disableAI "FSM";
                _unit disableAI "SUPPRESSION";
                _unit disableAI "COVER";
                _unit setUnitPos "UP";
                _unit allowFleeing 0;
                _unit setAnimSpeedCoef 1.2;

                if (_unit distance _target > _range) then {
                    _unit doMove (getPos _target);
                    _unit doWatch _target;
                };

                if (
                    _unit distance _target <= _range &&
                    {count activeMeleeUnits < maxMeleeUnits} &&
                    {(activeMeleeUnits findIf { _x == _unit }) == -1}
                ) then {
                    activeMeleeUnits pushBack _unit;

                    while {
                        alive _unit &&
                        alive _target &&
                        {_unit distance _target <= _range}
                    } do {
                        _unit playActionNow selectRandom ["vn_bayonet_bayonetstrike", "vn_bayonet_buttstrike"];
                        sleep 0.2;
                        _target setDamage (damage _target + 0.5);
                    };

                    activeMeleeUnits deleteAt (activeMeleeUnits findIf { _x == _unit });
                    _target = objNull;
                };
            };
        };

        sleep 2 + random 2;
    };
};

missionNamespace setVariable ["fnc_handleMeleeBehavior", fnc_handleMeleeBehavior];