fnc_spawnRadioStation = {
    params ["_pos", "_dir", "_caller"];
    if (!isServer) exitWith {};

    private _existing = missionNamespace getVariable ["activeRadioStation", objNull];
    if (!isNull _existing) exitWith {};

    private _activeZones = missionNamespace getVariable ["ActivatedZoneIDs", []];
    private _zonePool = missionNamespace getVariable ["fob_zonePool", []];

    private _validZone = false;

    {
        private _zoneName = _x select 0;
        private _center   = _x select 1;
        private _width    = _x select 2;
        private _height   = _x select 3;

        if (_zoneName in _activeZones) then {
            if (_pos inArea [_center, _width / 2, _height / 2, 0, true]) exitWith {
                _validZone = true;
            };
        };
    } forEach _zonePool;

    if (!_validZone) exitWith {};

    private _spawnPos = _pos;

    private _table = createVehicle ["Land_WoodenTable_small_F", _spawnPos, [], 0, "NONE"];
    _table setDir _dir;
    _table setPosATL _spawnPos;
    _table allowDamage false;
    _table enableSimulationGlobal false;
    _table setVectorUp surfaceNormal getPosATL _table;

    private _radio = createVehicle ["vn_b_prop_vrc12", _spawnPos, [], 0, "NONE"];
    _radio setDir _dir;
    _radio setPosATL (_spawnPos vectorAdd [0, 0, 0.80]);
    _radio allowDamage false;
    _radio enableSimulationGlobal false;
    _radio setVectorUp surfaceNormal getPosATL _radio;

    private _stationObjects = [_table, _radio];

    _radio setVariable ["terminalID", "sandbagTerminal_1", true];
    _radio setVariable ["sandbagSupply", 0, true];
    _radio setVariable ["trackedBuildObjects", [], true];
    _radio setVariable ["builtTypes", [], true];
    _radio setVariable ["stationObjects", _stationObjects, true];

    missionNamespace setVariable ["sandbagTerminal_1", _radio];
    missionNamespace setVariable ["activeRadioStation", _radio];
    publicVariable "sandbagTerminal_1";
    publicVariable "activeRadioStation";

    private _name = format ["Deployed by: %1", name _caller];
    ["StationStartup", [_name]] remoteExec ["BIS_fnc_showNotification", 0];

    private _areaMarker = "radioStationArea";
    private _labelMarker = "radioStationLabel";

    deleteMarker _areaMarker;
    deleteMarker _labelMarker;

    private _m1 = createMarker [_areaMarker, _spawnPos];
    _m1 setMarkerShape "ELLIPSE";
    _m1 setMarkerSize [100, 100];
    _m1 setMarkerColor "ColorBlue";
    _m1 setMarkerAlpha 0.5;

    private _m2 = createMarker [_labelMarker, _spawnPos];
    _m2 setMarkerType "b_installation";
    _m2 setMarkerText "Supply Depot - Supplies: 0";

    _radio setVariable ["stationMarker", _labelMarker, true];
    _radio setVariable ["stationAreaMarker", _areaMarker, true];

    [_radio] call fnc_updateStationMarker;
};

missionNamespace setVariable ["fnc_spawnRadioStation", fnc_spawnRadioStation];

fnc_updateStationMarker = {
    params ["_terminal"];
    if (isNull _terminal) exitWith {};

    private _markerName = _terminal getVariable ["stationMarker", ""];
    if (_markerName == "") exitWith {};

    private _supply = _terminal getVariable ["sandbagSupply", 0];
    private _built = _terminal getVariable ["stationObjects", []];
    private _count = count _built;

    _markerName setMarkerText format ["Supply Depot - Current Supplies: %1", _supply];
};

missionNamespace setVariable ["fnc_updateStationMarker", fnc_updateStationMarker];

fnc_serverPlaceModule = {
    if (!isServer) exitWith {};

    params ["_structureType", "_pos", "_dir"];

    private _terminal = missionNamespace getVariable ["activeRadioStation", objNull];
    if (isNull _terminal) exitWith {};

    private _center = getPosATL _terminal;

    if !(_pos inArea [_center, 100, 100, 0, true]) exitWith {
        ["Fail", ["You must place modules within range of the Radio Station."]] 
            remoteExec ["BIS_fnc_showNotification", remoteExecutedOwner];
    };

    private _buildables = [
        ["VehRefuel", "Land_vn_usaf_fueltank_75_01", 150],
        ["VehRearm", "Land_vn_us_vehicleammo", 500],
        ["VehRepair", "vn_us_komex_small_02", 300],
        ["Tower", "Land_ObservationTower_F", 12],
        ["CrateModule", "Land_vn_us_weapons_stack3", 500]
    ];

    private _entry = _buildables select { _x select 0 == _structureType };
    if (count _entry == 0) exitWith {};

    private _class = _entry select 0 select 1;
    private _cost  = _entry select 0 select 2;

    private _builtTypes = _terminal getVariable ["builtTypes", []];
    if (_structureType in _builtTypes) exitWith {};

    private _supply = _terminal getVariable ["sandbagSupply", 0];
    if (_supply < _cost) exitWith {
        ["Fail", ["Not enough supplies at the Radio Station."]] 
            remoteExec ["BIS_fnc_showNotification", remoteExecutedOwner];
    };

    _terminal setVariable ["sandbagSupply", _supply - _cost, true];
    [_terminal] call fnc_updateStationMarker;

    private _obj = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
    _obj setDir _dir;
    _obj allowDamage false;
    _obj enableSimulationGlobal false;

    private _tracked = _terminal getVariable ["trackedBuildObjects", []];
    _tracked pushBack _obj;
    _terminal setVariable ["trackedBuildObjects", _tracked, true];

    _builtTypes pushBack _structureType;
    _terminal setVariable ["builtTypes", _builtTypes, true];

    private _supportType = switch (_structureType) do {
        case "VehRearm": { "rearm" };
        case "VehRepair": { "repair" };
        default { "" };
    };

    if (_supportType != "") then {
        [_pos, _supportType, _terminal] call fnc_createSupportZone;
    };

    if (_structureType == "CrateModule") then {
        missionNamespace setVariable ["crateModuleObject", _obj];
        publicVariable "crateModuleObject";
    };

    ["Success", [format ["%1 module placed successfully.", _structureType]]] 
        remoteExec ["BIS_fnc_showNotification", remoteExecutedOwner];
};
missionNamespace setVariable ["fnc_serverPlaceModule", fnc_serverPlaceModule];

fnc_consumeSandbagsFromNearbyCrates = {
    if (!isServer) exitWith {};

    params ["_centerPos", "_radius", "_magType", "_count"];

    private _remaining = _count;

    private _crateClasses = ["vn_b_ammobox_supply_10"];
    private _heliClasses = [
        "vn_b_air_ch47_01_01",// not really needed anymore as it auto grabs from all vehicles configured correctly
        "vn_b_air_uh1d_02_03",
        "vn_b_air_uh1c_07_05"
    ];

    private _sourceClasses = _crateClasses + _heliClasses;
    private _sources = nearestObjects [_centerPos, _sourceClasses, _radius];

    {
        private _source = _x;
        if (_remaining <= 0) exitWith {};

        private _cargo = magazineCargo _source;
        private _filtered = [];

        private _initialRemaining = _remaining;

        {
            if (_x == _magType && _remaining > 0) then {
                _remaining = _remaining - 1;
            } else {
                _filtered pushBack _x;
            };
        } forEach _cargo;

        private _unique = [];
        private _counts = [];

        {
            private _index = _unique find _x;
            if (_index == -1) then {
                _unique pushBack _x;
                _counts pushBack 1;
            } else {
                _counts set [_index, (_counts select _index) + 1];
            };
        } forEach _filtered;

        clearMagazineCargoGlobal _source;

        for "_i" from 0 to (count _unique - 1) do {
            _source addMagazineCargoGlobal [_unique select _i, _counts select _i];
        };

        private _isCrate = typeOf _source in _crateClasses;
        private _drained = (_initialRemaining > _remaining);

        if (_isCrate && _drained) then {
            deleteVehicle _source;
        };
    } forEach _sources;

    private _removed = _count - _remaining;
    _removed
};

missionNamespace setVariable ["fnc_consumeSandbagsFromNearbyCrates", fnc_consumeSandbagsFromNearbyCrates];

fnc_exportSandbagsToCrate = {
    params ["_terminal"];
    if (!isServer || isNull _terminal) exitWith {};

    private _supply = _terminal getVariable ["sandbagSupply", 0];
    if (_supply <= 0) exitWith {};

    _terminal setVariable ["sandbagSupply", 0, true];
    [_terminal] call fnc_updateStationMarker;

    private _pos = getPosATL _terminal vectorAdd [12, 0, 0];
    private _crate = createVehicle ["vn_b_ammobox_supply_10", _pos, [], 0, "NONE"];
    clearMagazineCargoGlobal _crate;
    _crate addMagazineCargoGlobal ["vn_prop_fort_mag", _supply];

};

missionNamespace setVariable ["fnc_exportSandbagsToCrate", fnc_exportSandbagsToCrate];

fnc_resupplyTerminal = {
    params ["_terminal"];
    if (!isServer || isNull _terminal) exitWith {};

    private _pos = getPosATL _terminal;
    private _radius = 200;
    private _magType = "vn_prop_fort_mag";

    private _added = [_pos, _radius, _magType, 9999] call fnc_consumeSandbagsFromNearbyCrates;

    private _current = _terminal getVariable ["sandbagSupply", 0];
    _terminal setVariable ["sandbagSupply", _current + _added, true];
    [_terminal] call fnc_updateStationMarker;

};

missionNamespace setVariable ["fnc_resupplyTerminal", fnc_resupplyTerminal];

fnc_spawnCrateFromModule = {
    params ["_crateType"];
    if (!isServer) exitWith {};

    private _terminal = missionNamespace getVariable ["activeRadioStation", objNull];
    private _crateModule = missionNamespace getVariable ["crateModuleObject", objNull];
    if (isNull _terminal || isNull _crateModule) exitWith {};

    private _crateDefs = [
        ["MagsCrate", "vn_b_ammobox_full_02", 120],
        ["MedicalCrate", "vn_b_ammobox_supply_03", 90],
        ["AmmoLight", "vn_b_ammobox_supply_13", 60],
        ["GrenadeCrate", "vn_b_ammobox_full_10", 250],
        ["M60Crate", "vn_b_ammobox_wpn_06", 450],
        ["HeavyAmmo", "vn_b_ammobox_full_01", 75],
        ["Mk18Crate", "vn_b_ammobox_wpn_11", 650],
        ["SmallCrate", "vn_b_ammobox_supply_04", 50]
    ];

    private _entry = _crateDefs select { _x select 0 == _crateType };
    if (count _entry == 0) exitWith {};

    private _class = _entry select 0 select 1;
    private _cost  = _entry select 0 select 2;

    private _supply = _terminal getVariable ["sandbagSupply", 0];
    if (_supply < _cost) exitWith {};

    _terminal setVariable ["sandbagSupply", _supply - _cost, true];
    [_terminal] call fnc_updateStationMarker;

    private _spawnPos = _crateModule modelToWorld [6, 0, 0.1];
    private _crate = createVehicle [_class, _spawnPos, [], 0, "NONE"];
};

missionNamespace setVariable ["fnc_spawnCrateFromModule", fnc_spawnCrateFromModule];


