if (!hasInterface) exitWith {};

fob_rotationStep = 0.54;
fob_elevationStep = 0.025;

fob_ghostObj = objNull;
fob_ghostAngle = 0;
fob_ghostHeightOffset = 0;
fob_buildConfirmed = false;
fob_buildCancelled = false;


missionNamespace setVariable ["fob_BuildzonePool", [
  [[17574.8,8986.94,0], 500, 500],  //HueCity - Must specify a 0 for z axis in centerPos
  [[17128.5,11793,0], 450, 450],    //SamSong
  [[15106.2,11112.1,0], 600, 600],  //LangMau
  [[19607.2,6711.72,0], 600, 600],  //DaNang
  [[18415.4,4883.62,0], 550, 550],  //BaRia
  [[16025,2441.65,0], 420, 420],    //TamPep
  [[8465.92,5488.59,0], 500, 500],  //LongHai 
  [[10507.6,8341.97,0], 400, 400],  //NiemTin
  [[7351.1,9151.56,0], 600, 600],   //Lumphat
  [[5126.06,9473.18,0], 550, 550],  //ThungLungCao
  [[3534.01,8592.65,0], 550, 550],  //Sihanoukville
  [[2895.99,11800.4,0], 700, 700],  //BinhYen
  [[2161.52,13597.9,0], 600, 600],  //PhokHam
  [[7477.11,11601.6,0], 800, 800],  //Attapeu
  [[2763.88,16922,0], 500, 500],    //VaCang
  [[5494.97,16821,0], 650, 650],    //CrossRoads
  [[14923.1,5759.18,0], 550, 550],  //ChuChi
  [[10826.3,5877.04,0], 650, 650],  //CommsHill
  [[12683.1,9368.59,0], 550, 550],  //AshauValley
  [[12383.6,11096.3,0], 600, 600],  //BanhTrung
  [[15113.7,12950.6,0], 600, 600],  //HaiPhong
  [[13685.5,14262.6,0], 600, 600],  //NorthHanoi
  [[14081.5,15844.5,0], 500, 500],  //BaiChi
  [[12820.5,17188.5,0], 450, 450],  //SonTay
  [[13406.2,18828,0], 800, 800],    //TongMoo
  [[9151.23,16419.7,0], 650, 650],  //ThudRidge
  [[8797.17,13959.3,0], 600, 600],  //Bru
  [[6988.61,16627.8,0], 600, 600]   //KetThuc    
]];

fob_isEngineer = { player getUnitTrait "Construction" };


fob_getAimPos = {
    private _screenCenter = [0.5, 0.5];
    private _aimPos = screenToWorld _screenCenter;

    if (!(_aimPos isEqualType [] && {count _aimPos == 3})) exitWith { [] };

    private _distance = player distance _aimPos;
    if (_distance > 30) exitWith { [] };

    _aimPos
};

fob_cleanupGhost = {
    if (!isNull fob_ghostObj) then {
        deleteVehicle fob_ghostObj;
        fob_ghostObj = objNull;
    };
};

fob_createGhost = {
    params ["_class"];

    fob_ghostAngle = 0;
    fob_ghostHeightOffset = 0;

    if (!isNil "fob_ghostObj" && {!isNull fob_ghostObj}) then {
        deleteVehicle fob_ghostObj;
    };

    private _aimPos = [] call fob_getAimPos;
    if (count _aimPos == 0) exitWith {
	[format ["Too far to build — aim closer!", _cost]] remoteExec ["hint", player];
	
    };

    _aimPos set [2, (_aimPos select 2) + fob_ghostHeightOffset];

    fob_ghostObj = createVehicleLocal [_class, _aimPos, [], 0, "NONE"];
    fob_ghostObj setVectorUp surfaceNormal _aimPos;
    fob_ghostObj setDir fob_ghostAngle;
    fob_ghostObj allowDamage false;

    {
        fob_ghostObj setObjectTextureGlobal [_forEachIndex, "#(argb,8,8,3)color(0,1,1,0.3)"];
        fob_ghostObj setObjectMaterialGlobal [_forEachIndex, ""];
    } forEach getObjectTextures fob_ghostObj;

    fob_ghostObj enableSimulation false;
    fob_ghostObj setFeatureType 2;
    fob_ghostObj setCollisionLight false;
    fob_ghostObj disableCollisionWith player;
    fob_ghostObj disableCollisionWith vehicle player;
};

fob_confirmBuild = {
    params ["_class", "_cost"];

    private _itemType = "vn_prop_fort_mag";
    private _radioTableClass = "Land_WoodenTable_small_F";

    private _basePos = [] call fob_getAimPos;
    if (count _basePos == 0) exitWith {
        [format ["Too far to build — aim closer!", _cost]] remoteExec ["hint", player];
        [] call fob_cleanupGhost;
        false
    };

    private _finalPos = +_basePos;
    _finalPos set [2, (_finalPos select 2) + fob_ghostHeightOffset];

    if (_class == _radioTableClass) then {

        [_finalPos, fob_ghostAngle, player] remoteExec ["fnc_spawnRadioStation", 2];

    } else {

        [ getPosASL player,
          _class,
          _cost,
          _itemType,
          _finalPos,
          fob_ghostAngle,
          surfaceNormal _finalPos,
          player
        ] remoteExec ["fob_serverBuildHandler", 2];
    };

    [] call fob_cleanupGhost;
    true
};

fob_startBuildFlow = {
    params ["_class", "_cost", "_otherclass"];

    fob_buildConfirmed = false;
    fob_buildCancelled = false;

    [_otherclass] call fob_createGhost;
    [] call fob_bindBuildControls;

    [format ["Use Q/E to rotate, R/F to raise/lower, SPACE to confirm, ESC to cancel.", _cost]] remoteExec ["hint", player];

    [_class, _cost] spawn {
        params ["_class", "_cost"];

        while { !isNull fob_ghostObj && !fob_buildConfirmed && !fob_buildCancelled } do {
            private _aimPos = [] call fob_getAimPos;
            if (count _aimPos == 0) then {
                fob_ghostObj hideObject true;
            } else {
                fob_ghostObj hideObject false;
                fob_ghostObj setPosATL [
                    (_aimPos select 0),
                    (_aimPos select 1),
                    (_aimPos select 2) + fob_ghostHeightOffset
                ];
                fob_ghostObj setDir fob_ghostAngle;
            };

            sleep 0.05;
        };

        if (fob_buildConfirmed) then {
            private _success = [_class, _cost] call fob_confirmBuild;
            if (!_success) then {
		[format ["Build failed.", _cost]] remoteExec ["hint", player];
            };
        } else {
            [] call fob_cleanupGhost;
	    [format ["Build cancelled.", _cost]] remoteExec ["hint", player];
        };
    };
};

fob_bindBuildControls = {
    waitUntil { !isNull findDisplay 46 };

    (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_display", "_keyCode"];

        if (isNull fob_ghostObj) exitWith { false };

        switch (_keyCode) do {
            case 16: { fob_ghostAngle = fob_ghostAngle - fob_rotationStep }; // Q
            case 18: { fob_ghostAngle = fob_ghostAngle + fob_rotationStep }; // E
            case 19: { fob_ghostHeightOffset = fob_ghostHeightOffset + fob_elevationStep }; // R
            case 33: { fob_ghostHeightOffset = fob_ghostHeightOffset - fob_elevationStep }; // F
            case 57: { fob_buildConfirmed = true }; // SPACE
            case 1:  { fob_buildCancelled = true }; // ESC
        };

        false
    }];
};

fnc_isBuildAllowedInZonePool = {
    params ["_buildPos"];
    private _zones = missionNamespace getVariable ["fob_BuildzonePool", []];
    private _flatPos = [_buildPos select 0, _buildPos select 1];

    private _result = false;

    {
        private _zoneCenter  = _x select 0;
        private _zoneWidth   = _x select 1;
        private _zoneHeight  = _x select 2;

        private _flatCenter = [_zoneCenter select 0, _zoneCenter select 1];
        private _inside = _flatPos inArea [_flatCenter, _zoneWidth, _zoneHeight, 0, false, 0];

        if (_inside) then {
            _result = true;
        };
    } forEach _zones;

    _result
};

fnc_validateBuildZone = {
    private _pos = getPosATL player;
    private _canBuild = [_pos] call fnc_isBuildAllowedInZonePool;

    if (_canBuild) then {
        createDialog "FobMenuDialog";
    } else {
	["You are outside of a buildable area. You may only build inside Designated AOs."] remoteExec ["hint", player];
    };
};

fob_openBuildMenu = {
    if (
        !isNull findDisplay 9000 ||
        !isNull findDisplay 9050 ||
        !isNull findDisplay 9100 ||
        !isNull findDisplay 9200 ||
        !isNull findDisplay 9300 ||
        !isNull findDisplay 9400 ||
        !isNull findDisplay 9600 ||
        !isNull findDisplay 9400 ||
        !isNull findDisplay 9700
    ) exitWith {};

    if (!call fob_isEngineer) exitWith {
        ["RoleConstructionIcon", ["Only Players With the Construction Role can Build."]] remoteExec ["BIS_fnc_showNotification", player];
    };

    [] call fnc_validateBuildZone;
};

ui_bindKeys = {
    waitUntil { !isNull findDisplay 46 };
    (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_display", "_keyCode"];
        if (_keyCode isEqualTo 49) then {
            [] call fob_openBuildMenu;
	    fob_ghostAngle = 0;
            fob_ghostHeightOffset = 0;
	    [] call fob_cleanupGhost;
	    
        };
        false
    }];
};

missionNamespace setVariable ["ui_bindKeys", ui_bindKeys];

fob_tryRemoveFromInventory = {
    params ["_itemType", "_cost", "_playerID", "_class", "_finalPos", "_ghostAngle"];

    private _player = player;
    private _count = { _x == _itemType } count magazines _player;
    private _success = false;

    if (_count >= _cost) then {
        for "_i" from 1 to _cost do {
            _player removeMagazine _itemType;
        };
        _success = true;
    };

    [_success, _playerID, _class, _cost, _finalPos, _ghostAngle] remoteExec ["fob_continueBuildFromInventory", 2];
};

missionNamespace setVariable ["fob_tryRemoveFromInventory", fob_tryRemoveFromInventory];