fnc_fire_mortar_atPlayer = {
    params ["_unit","_ammo","_rounds","_delay","_spread","_area","_area_a","_area_b"];

    if (isServer) then {
        if (_ammo == "") then {
            private _ammoArray = getArtilleryAmmo [_unit];
            _ammo = _ammoArray select 0;
        };

        for "_i" from 1 to _rounds do {
            private _playerArray = (allPlayers + (allUnits select {side _x == west})) - entities "HeadlessClient_F";
            private _randPlayer = selectRandom _playerArray;

            if (_randPlayer inArea [_area, _area_a, _area_b, 0, false, 500]) then {
                private _newTarget = [[[getPos _randPlayer, _spread]], []] call BIS_fnc_randomPos;
                _unit commandArtilleryFire [_newTarget, _ammo, 1];
            };

            sleep _delay;
        };
    };
};

missionNamespace setVariable ["fnc_fire_mortar_atPlayer", fnc_fire_mortar_atPlayer];

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

fnc_unitInit = {
    params ["_group", "_area", "_area_a", "_area_b", "_units"];

    {
        private _unit = _x;

        [_group, _area, _area_a, _area_b, _unit] spawn (missionNamespace getVariable "fnc_dynamicWaypointLoop");
        [_unit] spawn (missionNamespace getVariable "fnc_handleMeleeBehavior");

        _unit setSkill ["aimingShake", 0.5];
        _unit setSkill ["aimingAccuracy", 0.06];
        _unit setSkill ["aimingSpeed", 0.55];
        _unit setSkill ["commanding", 1];
        _unit setSkill ["reloadSpeed", 0.65];
        _unit setSkill ["spotDistance", 0.52];
        _unit setSkill ["spotTime", 0.48];
    } forEach _units;
};

fnc_unitInit_other = {
    params ["_group", "_units"];

    {
        private _unit = _x;

        _unit setSkill ["aimingShake", 0.4];
        _unit setSkill ["aimingAccuracy", 0.08];
        _unit setSkill ["aimingSpeed", 0.58];
        _unit setSkill ["commanding", 1];
        _unit setSkill ["reloadSpeed", 0.65];
        _unit setSkill ["spotDistance", 0.65];
        _unit setSkill ["spotTime", 0.55];
    } forEach _units;
};

fnc_spawn_troops = {
    if (!isServer) exitWith {};

    if (diag_fps <= 20) exitWith {
        diag_log format ["[fnc_spawn_troops] Skipped — Server FPS too low: %1", diag_fps];
    };

    params ["_unitCount", "_spawnPos", "_zoneCenter", "_zoneWidth", "_zoneHeight"];

    private _existing = missionNamespace getVariable ["HarassmentUnits", []];
    private _aliveUnits = _existing select { alive _x };
    private _aliveCount = count _aliveUnits;

    if ((_aliveCount + _unitCount) > 35) exitWith {
        diag_log format [
            "[fnc_spawn_troops] Spawn aborted — alive harassment units: %1, requested: %2, cap: 26",
            _aliveCount, _unitCount
        ];
    };

    private _group = createGroup [east, true];
    private _spawnedUnits = [];

    for "_i" from 1 to _unitCount do {
        private _nva_vc_array = [
            "vn_o_men_nva_11", "vn_o_men_nva_05", "vn_o_men_vc_local_15", "vn_o_men_vc_local_18",
            "vn_o_men_vc_01", "vn_o_men_vc_03", "vn_o_men_vc_06", "vn_o_men_nva_19",
            "vn_o_men_nva_25", "vn_o_men_nva_50", "vn_o_men_nva_28", "vn_o_men_nva_03",
            "vn_o_men_nva_09", "vn_o_men_nva_07"
        ];

        private _rand_nva_vc = selectRandom _nva_vc_array;
        private _offset = [random 10 - 5, random 10 - 5, 0];
        private _unitPos = _spawnPos vectorAdd _offset;

        private _unit = _group createUnit [_rand_nva_vc, _unitPos, [], 0, "NONE"];

        if (!isNull _unit) then {
            _spawnedUnits pushBack _unit;
        } else {
            diag_log format ["[fnc_spawn_troops] WARNING: Failed to spawn unit of type %1 at %2", _rand_nva_vc, _unitPos];
        };

        sleep 0.25;
    };

    [_group, _zoneCenter, _zoneWidth, _zoneHeight, _spawnedUnits] call fnc_unitInit;
    missionNamespace setVariable ["HarassmentUnits", _aliveUnits + _spawnedUnits];
};

missionNamespace setVariable ["fnc_spawn_troops", fnc_spawn_troops];

fnc_spawn_CAtroops = {
    if (!isServer) exitWith {};

    if (diag_fps <= 34) exitWith {
        diag_log format ["[fnc_spawn_CAtroops] Skipped — Server FPS too low: %1", diag_fps];
    };

    params ["_unitCount", "_spawnPos", "_zoneCenter", "_zoneWidth", "_zoneHeight"];

    private _existing = missionNamespace getVariable ["CounterattackUnits", []];
    private _aliveUnits = _existing select { alive _x };
    private _aliveCount = count _aliveUnits;

    if ((_aliveCount + _unitCount) > 60) exitWith {
        diag_log format [
            "[fnc_spawn_CAtroops] Spawn aborted — alive counterattack units: %1, requested: %2, cap: 60",
            _aliveCount, _unitCount
        ];
    };

    private _group = createGroup [east, true];
    private _spawnedUnits = [];

    for "_i" from 1 to _unitCount do {
        private _nva_vc_array = [
            "vn_o_men_nva_11", "vn_o_men_nva_05", "vn_o_men_vc_local_15", "vn_o_men_vc_local_18",
            "vn_o_men_vc_01", "vn_o_men_vc_03", "vn_o_men_vc_06", "vn_o_men_nva_19",
            "vn_o_men_nva_25", "vn_o_men_nva_50", "vn_o_men_nva_28", "vn_o_men_nva_03",
            "vn_o_men_nva_09", "vn_o_men_nva_07"
        ];

        private _rand_nva_vc = selectRandom _nva_vc_array;
        private _offset = [random 10 - 5, random 10 - 5, 0];
        private _unitPos = _spawnPos vectorAdd _offset;

        private _unit = _group createUnit [_rand_nva_vc, _unitPos, [], 0, "NONE"];

        if (!isNull _unit) then {
            _spawnedUnits pushBack _unit;
        } else {
            diag_log format ["[fnc_spawn_CAtroops] WARNING: Failed to spawn CA unit of type %1 at %2", _rand_nva_vc, _unitPos];
        };

        sleep 0.25;
    };

    [_group, _zoneCenter, _zoneWidth, _zoneHeight, _spawnedUnits] call fnc_unitInit;
    missionNamespace setVariable ["CounterattackUnits", _aliveUnits + _spawnedUnits];
};

missionNamespace setVariable ["fnc_spawn_CAtroops", fnc_spawn_CAtroops];

fnc_spawnIntelDefenders = {
    if (!isServer) exitWith {};

    params ["_radios"];

    {
        private _radio = _x;
        if (isNull _radio) then { continue };

        private _pos = getPosATL _radio;

        private _nearPlayers = allPlayers select { _x distance2D _pos < 300 };
        if (count _nearPlayers > 0) then {
            diag_log "[IntelDefenders] Players too close — delaying spawn.";
            continue;
        };

        private _nvaPool = [
            "vn_o_men_nva_11", "vn_o_men_nva_05", "vn_o_men_vc_local_15", "vn_o_men_vc_local_18",
            "vn_o_men_nva_19", "vn_o_men_nva_25", "vn_o_men_nva_50", "vn_o_men_nva_28", "vn_o_men_nva_03",
            "vn_o_men_nva_09", "vn_o_men_nva_07"
        ];

        private _spawned = [];
        private _groups = [];

        for "_g" from 1 to 2 do {
            private _grp = createGroup [east, true];
            private _units = [];

            for "_i" from 1 to 3 do {
                private _type = selectRandom _nvaPool;
                private _offset = [random 10 - 5, random 10 - 5, 0];
                private _unitPos = _pos vectorAdd _offset;

                private _unit = _grp createUnit [_type, _unitPos, [], 0, "NONE"];
                if (!isNull _unit) then {
                    _units pushBack _unit;
                    _spawned pushBack _unit;
                };
                sleep 0.1;
            };

            [_grp, _units] call fnc_unitInit_other;

            _groups pushBack _grp;
        };

        {
            private _grp = _x;

            for "_w" from 1 to 4 do {
                private _radius = 75 + random 75;
                private _angle = random 360;

                private _wpPos = [
                    (_pos select 0) + (sin _angle * _radius),
                    (_pos select 1) + (cos _angle * _radius),
                    0
                ];

                private _wp = _grp addWaypoint [_wpPos, 0];
                _wp setWaypointType "MOVE";
                _wp setWaypointSpeed "LIMITED";
                _wp setWaypointBehaviour "SAFE";
            };

            private _cycle = _grp addWaypoint [_pos, 0];
            _cycle setWaypointType "CYCLE";

        } forEach _groups;

        private _existing = missionNamespace getVariable ["IntelDefenderUnits", []];
        missionNamespace setVariable ["IntelDefenderUnits", _existing + _spawned];

        diag_log format ["[IntelDefenders] Spawned %1 defenders for radio at %2", count _spawned, _pos];

    } forEach _radios;
};

missionNamespace setVariable ["fnc_spawnIntelDefenders", fnc_spawnIntelDefenders];

fnc_saboteurAction = {
    params ["_unit"];

    private _radio = missionNamespace getVariable ["activeRadioStation", objNull];
    if (isNull _radio) exitWith {};

    private _pos = getPosATL _radio;

    private _charge = createMine ["vn_mine_tm57", _pos, [], 0];
    _unit addOwnedMine _charge;

    diag_log "[Saboteurs] planted TM-57 — 40s timer started.";

    [_charge, _radio, _unit] spawn {
        params ["_boom", "_radio", "_unit"];

        sleep 40;

        if (!isNull _boom) then {
            _boom setDamage 1;
        };

        if (!isNull _radio) then {
            [_radio, _unit] call (missionNamespace getVariable "fnc_shutdownStation");
        };
    };

    private _grp = group _unit;

    private _escape = [
        (_pos select 0) + (random 600 - 300),
        (_pos select 1) + (random 600 - 300),
        0
    ];

    private _wp = _grp addWaypoint [_escape, 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointSpeed "FULL";
    _wp setWaypointBehaviour "AWARE";
    _wp setWaypointStatements ["true", "[] call fnc_cleanupSaboteurs;"];
};

missionNamespace setVariable ["fnc_saboteurAction", fnc_saboteurAction];

fnc_cleanupSaboteurs = {
    private _units = missionNamespace getVariable ["ActiveSaboteurUnits", []];

    {
        if (!isNull _x) then { deleteVehicle _x };
    } forEach _units;

    missionNamespace setVariable ["ActiveSaboteurUnits", []];
    diag_log "[Saboteurs] Cleanup complete.";
};

missionNamespace setVariable ["fnc_cleanupSaboteurs", fnc_cleanupSaboteurs];


fnc_spawnSaboteurTeam = {
    if (!isServer) exitWith {};

    private _radio = missionNamespace getVariable ["activeRadioStation", objNull];
    if (isNull _radio) exitWith {
        diag_log "[Saboteurs] No active supply depot — aborting.";
    };

    private _targetPos = getPosATL _radio;

    private _safezones = [
        [[16311.8, 7101.64, 0], 1500, 1500]
    ];

    private _saboteurTypes = [
        "vn_o_men_nva_dc_09",
        "vn_o_men_nva_dc_05",
        "vn_o_men_nva_dc_07",
        "vn_o_men_nva_dc_02",
        "vn_o_men_nva_dc_14",
        "vn_o_men_nva_dc_08",
	"vn_o_men_nva_dc_06",
	"vn_o_men_nva_dc_04"
    ];

    private _spawnPos = [0,0,0];
    private _attempts = 0;

    while { _attempts < 200 } do {
        _attempts = _attempts + 1;

        private _angle = random 360;
        private _dist = 1200 + random 200;

        _spawnPos = [
            (_targetPos select 0) + sin _angle * _dist,
            (_targetPos select 1) + cos _angle * _dist,
            0
        ];

        private _nearPlayers = allPlayers select { _x distance2D _spawnPos < 400 };
        if (count _nearPlayers > 0) then { continue };

        private _insideSafezone = false;

        {
            private _szPos = _x select 0;
            private _szW   = _x select 1;
            private _szH   = _x select 2;

            if (_spawnPos inArea [_szPos, _szW, _szH, 0, false]) exitWith {
                _insideSafezone = true;
            };
        } forEach _safezones;

        if (_insideSafezone) then { continue };

        break;
    };

    private _grp = createGroup [east, true];
    private _units = [];

    for "_i" from 1 to 5 do {
        private _class = selectRandom _saboteurTypes;
        private _u = _grp createUnit [_class, _spawnPos, [], 0, "NONE"];
        if (!isNull _u) then { _units pushBack _u };
    };

    {
        _x setSkill ["spotDistance", 0.2];
        _x setSkill ["courage", 0.9];
    } forEach _units;

    private _isNight = (dayTime >= 18 || dayTime <= 5.6);

    _grp setBehaviour "STEALTH";
    _grp setSpeedMode "FULL";

    {
        if (_isNight) then {
            _x setUnitPos "MIDDLE";
        } else {
            _x setUnitPos "UP";
        };
        _x forceSpeed -1;
    } forEach _units;

    private _wp = _grp addWaypoint [_targetPos, 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "STEALTH";
    _wp setWaypointSpeed "FULL";
    _wp setWaypointCompletionRadius 5;

    _wp setWaypointStatements [
        "true",
        "[leader this] call fnc_saboteurAction;"
    ];

    missionNamespace setVariable ["ActiveSaboteurUnits", _units];
};

missionNamespace setVariable ["fnc_spawnSaboteurTeam", fnc_spawnSaboteurTeam];

fnc_cleanupHarassmentUnits = {
    private _units = missionNamespace getVariable ["HarassmentUnits", []];
    private _players = allPlayers select { alive _x };

    private _safeUnits = [];
    private _deletedCount = 0;

    {
        private _unit = _x;
        private _tooClose = { _unit distance _x < 500 } count _players > 0;

        if (!isNull _unit && {!_tooClose}) then {
            deleteVehicle _unit;
            _deletedCount = _deletedCount + 1;
        } else {
            _safeUnits pushBack _unit;
        };
    } forEach _units;

    missionNamespace setVariable ["HarassmentUnits", _safeUnits];
    diag_log format ["fnc_cleanupHarassmentUnits: Deleted %1 units, preserved %2 near players.", _deletedCount, count _safeUnits];
};

missionNamespace setVariable ["fnc_cleanupHarassmentUnits", fnc_cleanupHarassmentUnits];

fnc_cleanupCounterattackUnits = {
    private _units = missionNamespace getVariable ["CounterattackUnits", []];
    private _players = allPlayers select { alive _x };

    private _safeUnits = [];
    private _deletedCount = 0;

    {
        private _unit = _x;
        private _tooClose = { _unit distance _x < 600 } count _players > 0;

        if (!isNull _unit && {!_tooClose}) then {
            deleteVehicle _unit;
            _deletedCount = _deletedCount + 1;
        } else {
            _safeUnits pushBack _unit;
        };
    } forEach _units;

    missionNamespace setVariable ["CounterattackUnits", _safeUnits];
    diag_log format ["fnc_cleanupCounterattackUnits: Deleted %1 units, preserved %2 near players.", _deletedCount, count _safeUnits];
};

missionNamespace setVariable ["fnc_cleanupCounterattackUnits", fnc_cleanupCounterattackUnits];

fnc_cleanupIntelDefenders = {
    private _units = missionNamespace getVariable ["IntelDefenderUnits", []];
    private _players = allPlayers select { alive _x };

    private _safe = [];
    private _deleted = 0;

    {
        private _unit = _x;
        private _tooClose = { _unit distance _x < 500 } count _players > 0;

        if (!isNull _unit && {!_tooClose}) then {
            deleteVehicle _unit;
            _deleted = _deleted + 1;
        } else {
            _safe pushBack _unit;
        };
    } forEach _units;

    missionNamespace setVariable ["IntelDefenderUnits", _safe];
    diag_log format ["[IntelDefenders] Deleted %1, preserved %2 near players.", _deleted, count _safe];
};
missionNamespace setVariable ["fnc_cleanupIntelDefenders", fnc_cleanupIntelDefenders];

fnc_pruneCombatUnits = {

    private _harass = missionNamespace getVariable ["HarassmentUnits", []];
    private _harassAlive = _harass select { alive _x };
    missionNamespace setVariable ["HarassmentUnits", _harassAlive];

    private _counter = missionNamespace getVariable ["CounterattackUnits", []];
    private _counterAlive = _counter select { alive _x };
    missionNamespace setVariable ["CounterattackUnits", _counterAlive];

    private _intel = missionNamespace getVariable ["IntelDefenderUnits", []];
    private _intelAlive = _intel select { alive _x };
    missionNamespace setVariable ["IntelDefenderUnits", _intelAlive];

    diag_log format [
        "[fnc_pruneCombatUnits] Harass: %1 | Counter: %2 | Intel: %3", count _harassAlive, count _counterAlive, count _intelAlive];
};

missionNamespace setVariable ["fnc_pruneCombatUnits", fnc_pruneCombatUnits];


fnc_completeZone = {
    [] call (missionNamespace getVariable "fnc_cleanupOldBuilds");
    private _zoneID = missionNamespace getVariable ["ActiveZoneID", nil];
    if (!isNil "_zoneID") then {
        private _completed = missionNamespace getVariable ["CompletedZoneIDs", []];
        _completed pushBackUnique _zoneID;
        missionNamespace setVariable ["CompletedZoneIDs", _completed];
    };

    {
        if (!isNull _x) then { deleteVehicle _x };
    } forEach (missionNamespace getVariable ["ActiveIntelObjects", []]);

    missionNamespace setVariable ["ActiveIntelObjects", []];
    missionNamespace setVariable ["ActiveIntelRadios", []];
    missionNamespace setVariable ["IntelFound", false];
    missionNamespace setVariable ["activeIntelRadio", objNull];

    missionNamespace setVariable ["ZoneActive", false];
    missionNamespace setVariable ["ActiveZoneID", nil];
    missionNamespace setVariable ["ActiveZone_startTime", nil];
    missionNamespace setVariable ["ActiveZoneCenter", nil];
    missionNamespace setVariable ["ActiveZoneWidth", nil];
    missionNamespace setVariable ["ActiveZoneHeight", nil];
    missionNamespace setVariable ["ActiveTasks", []];

    terminate (missionNamespace getVariable ["ZoneLogicThread", scriptNull]);
    missionNamespace setVariable ["ZoneLogicThread", nil];

    missionNamespace setVariable ["Active_aaUnits", []];
    missionNamespace setVariable ["Active_mortarUnits", []];

    terminate (missionNamespace getVariable ["HarassmentThread", scriptNull]);
    missionNamespace setVariable ["HarassmentThread", nil];

    terminate (missionNamespace getVariable ["CounterattackThread", scriptNull]);
    missionNamespace setVariable ["CounterattackThread", nil];

    terminate (missionNamespace getVariable ["IntelDefenderThread", scriptNull]);
    missionNamespace setVariable ["IntelDefenderThread", nil];

    terminate (missionNamespace getVariable ["SaboteurThread", scriptNull]);
    missionNamespace setVariable ["SaboteurThread", nil];

    missionNamespace setVariable ["reconTraitChecked", []];

    [] call (missionNamespace getVariable "fnc_startZoneLogicThread");
};

missionNamespace setVariable ["fnc_completeZone", fnc_completeZone];

