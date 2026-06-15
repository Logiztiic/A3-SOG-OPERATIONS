fnc_arraySum = {
    params ["_arr"];
    private _sum = 0;
    { _sum = _sum + _x } forEach _arr;
    _sum
};

fnc_createIntelSites = {
    if (!isServer) exitWith {};

    params ["_centerPos", "_areaWidth", "_areaHeight"];

    private _zoneID = missionNamespace getVariable ["ActiveZoneID", ""];
    if (_zoneID isEqualTo "") exitWith {};

    private _intelPools = missionNamespace getVariable ["IntelLocationPools", []];
    private _entry = _intelPools select { _x select 0 == _zoneID };

    if (count _entry == 0) exitWith {
        diag_log format ["[Intel] No intel pool found for zone %1", _zoneID];
    };

    private _locations = (_entry select 0) select 1;

    private _minSites = 3;
    private _maxSites = 5;

    private _count = _maxSites min (count _locations);
    if (_count < _minSites) then { _count = _minSites min (count _locations) };

    private _chosen = [];

    private _safeLocations = _locations select {
        private _pos = _x;
        private _near = allPlayers select { _pos distance2D _x < 300 };
        (count _near) == 0
    };

    private _pool = if (count _safeLocations > 0) then { _safeLocations } else { _locations };

    for "_i" from 1 to _count do {
        if (count _pool == 0) exitWith {};

        private _pos = selectRandom _pool;
        _chosen pushBack _pos;

        _pool = _pool - [_pos];
    };

    private _spawned = [];
    private _realIndex = floor random _count;

    {
        private _pos = _x;

        // spawn canopy
        private _canopy = createVehicle ["Land_vn_o_Shelter_02", _pos, [], 0, "CAN_COLLIDE"];

        // spawn table
        private _tablePos = _pos vectorAdd [0,0,0.1];
        private _table = createVehicle ["Land_WoodenTable_small_F", _tablePos, [], 0, "CAN_COLLIDE"];

        // spawn radio
        private _radioPos = _table modelToWorld [0,0.2,0.7];
        private _radio = createVehicle ["vn_o_prop_t102e_01", _radioPos, [], 0, "CAN_COLLIDE"];

        _radio setVariable ["isIntelRadio", (_forEachIndex == _realIndex), true];
        _radio setVariable ["intelChecked", false, true];

        _spawned pushBack _canopy;
        _spawned pushBack _table;
        _spawned pushBack _radio;

    } forEach _chosen;

    missionNamespace setVariable ["ActiveIntelObjects", _spawned];
    missionNamespace setVariable ["ActiveIntelRadios", _spawned select { typeOf _x == "vn_o_prop_t102e_01" }];

    diag_log format ["[Intel] Spawned %1 intel sites for zone %2", _count, _zoneID];
};

missionNamespace setVariable ["fnc_createIntelSites", fnc_createIntelSites];

fnc_setupArea = {
    if (!isServer) exitWith {};

    params ["_centerPos"];

    private _zoneRadius = 250;

    private _aaTypes = ["vn_o_nva_65_static_zgu1_01", "vn_o_nva_65_static_zpu4"];
    private _mortarTypes = ["vn_o_nva_65_static_mortar_type63", "vn_o_nva_65_static_mortar_type53"];

    private _northWest = _centerPos vectorAdd [-_zoneRadius / 2,  _zoneRadius / 2, 0];
    private _northEast = _centerPos vectorAdd [ _zoneRadius / 2,  _zoneRadius / 2, 0];
    private _southWest = _centerPos vectorAdd [-_zoneRadius / 2, -_zoneRadius / 2, 0];
    private _southEast = _centerPos vectorAdd [ _zoneRadius / 2, -_zoneRadius / 2, 0];
    private _subzones = [_northWest, _northEast, _southWest, _southEast];

    private _placedPositions = [];

    private _findSafePos = {
        params ["_origin", "_radius", "_existing"];
        private _pos = [0, 0, 0];
        private _attempts = 0;

        while { _attempts < 350 } do {
            _pos = _origin vectorAdd [
                random _radius - (_radius / 2),
                random _radius - (_radius / 2),
                0
            ];

            private _surface = surfaceIsWater _pos;

            private _sampleOffset = [5, 0, 0];
            private _samplePos = _pos vectorAdd _sampleOffset;
            private _height1 = getTerrainHeight _pos;
            private _height2 = getTerrainHeight _samplePos;
            private _slope = abs (_height2 - _height1);
            private _flatEnough = _slope < 0.2;

            private _terrainClutter = nearestTerrainObjects [
                _pos,
                ["BUILDING", "ROCK", "WALL", "FENCE", "RUIN", "BUSH"],
                15
            ];
            private _terrainObstructive = count _terrainClutter > 0;

            private _nearby = nearestObjects [_pos, [], 10];
            private _insideBoundingBox = {
                private _bb = boundingBoxReal _x;
                private _center = getPosWorld _x;
                private _min = _bb select 0;
                private _max = _bb select 1;
                private _width = abs ((_max select 0) - (_min select 0));
                private _height = abs ((_max select 1) - (_min select 1));
                private _angle = getDir _x;

                _pos inArea [_center, _width, _height, _angle, true, 0]
            } count _nearby > 0;

            private _clearAbove = count (lineIntersectsSurfaces [
                _pos vectorAdd [0, 0, 0.5],
                _pos vectorAdd [0, 0, 3],
                objNull, objNull, true, 1, "VIEW", "FIRE"
            ]) == 0;

            private _tooClose = {_pos distance _x < 200} count _existing > 0;

            if (!_surface && _flatEnough && !_terrainObstructive && !_insideBoundingBox && _clearAbove && !_tooClose) exitWith {
                diag_log format ["Accepted spawn position at %1 after %2 attempts", _pos, _attempts + 1];
                _pos
            };

            _attempts = _attempts + 1;
            sleep 0.02;
        };

        diag_log format ["Fallback spawn position used after 300 failed attempts: %1", _pos];
        _pos
    };

    private _aaCount = floor random [2, 3, 3];
    private _aaGuns = [];

    for "_i" from 1 to _aaCount do {
        private _aaPos = [_centerPos, _zoneRadius, _placedPositions] call _findSafePos;
        private _aaType = selectRandom _aaTypes;
        private _aaResult = [_aaPos, 180, _aaType, east] call BIS_fnc_spawnVehicle;
        private _aaGun = _aaResult select 0;

        if (!isNull _aaGun && {alive _aaGun}) then {
            _aaGun allowDamage false;
            [_aaGun] spawn { sleep 2; _this select 0 allowDamage true; };
            _aaGuns pushBack _aaGun;
            _placedPositions pushBack _aaPos;

            [_aaGun] call (missionNamespace getVariable "fnc_autoTargetAA");
        } else {
            diag_log format ["WARNING: AA gun %1 failed to spawn or is dead", _aaType];
        };
    };

    if (count _aaGuns == 0) then {
        diag_log "WARNING: No valid AA guns spawned — objective tracking may fail.";
    };

    private _mortarCount = floor random [1, 2, 3];
    private _mortarGuns = [];

    for "_i" from 1 to _mortarCount do {
        private _origin = selectRandom _subzones;
        private _mortarPos = [_origin, _zoneRadius / 2, _placedPositions] call _findSafePos;
        private _mortarType = selectRandom _mortarTypes;
        private _mortarResult = [_mortarPos, 180, _mortarType, east] call BIS_fnc_spawnVehicle;
        private _mortarGun = _mortarResult select 0;

        if (!isNull _mortarGun && {alive _mortarGun}) then {
            _mortarGun allowDamage false;
            [_mortarGun] spawn { sleep 2; _this select 0 allowDamage true; };
            _mortarGuns pushBack _mortarGun;
            _placedPositions pushBack _mortarPos;
        } else {
            diag_log format ["WARNING: Mortar gun %1 failed to spawn or is dead", _mortarType];
        };
    };

    if (count _mortarGuns == 0) then {
        diag_log "WARNING: No valid mortar units spawned — objective tracking may fail.";
    };

    missionNamespace setVariable ["Active_aaUnits", _aaGuns];
    missionNamespace setVariable ["Active_mortarUnits", _mortarGuns];
};

missionNamespace setVariable ["fnc_setupArea", fnc_setupArea];

fnc_monitorDefendZone = {
    params ["_zoneCenter", "_zoneWidth", "_zoneHeight", "_taskID", "_holdDuration"];

    [_zoneCenter, _zoneWidth, _zoneHeight, _taskID, _holdDuration] spawn {
        params ["_center", "_width", "_height", "_taskID", "_duration"];

        private _startTime = -1;

        while {true} do {
            private _playersInZone = allPlayers select {
                alive _x && _x inArea [_center, _width, _height, 0, false, 200]
            };

            if (count _playersInZone > 0) then {
                if (_startTime < 0) then {
                    _startTime = time;
                };

                if ((time - _startTime) >= _duration) then {
                    [_taskID] call (missionNamespace getVariable "fnc_completeTask");
                    private _zoneID = missionNamespace getVariable ["ActiveZoneID", ""];
		    [_zoneID] remoteExec ["fnc_updateZoneMarkerColor", 0, true];
                    break;
                };
            } else {
                _startTime = -1;
            };

            sleep 10;
        };
    };
};

missionNamespace setVariable ["fnc_monitorDefendZone", fnc_monitorDefendZone];

