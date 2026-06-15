if (!hasInterface) exitWith {};

ui_bind6Key_radioOnly = {
    waitUntil { !isNull findDisplay 46 };

    (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_display", "_keyCode"];

        if (_keyCode isEqualTo 7) then {

            // Prevent opening if any other UI is open
            if (
                !isNull findDisplay 9000 ||
                !isNull findDisplay 9050 ||
                !isNull findDisplay 9100 ||
                !isNull findDisplay 9200 ||
                !isNull findDisplay 9300 ||
                !isNull findDisplay 9400 ||
                !isNull findDisplay 9600 ||
                !isNull findDisplay 9700
            ) exitWith {};

            private _terminal = missionNamespace getVariable ["activeRadioStation", objNull];
            private _crateModule = missionNamespace getVariable ["crateModuleObject", objNull];

            private _nearTerminal = !isNull _terminal && {player distance _terminal < 3};
            private _nearCrateModule = !isNull _crateModule && {player distance _crateModule < 3};
	    private _nearIntelRadio = objNull;
            {
               if (player distance _x < 3) exitWith {
                   _nearIntelRadio = _x;
               };
            } forEach (missionNamespace getVariable ["ActiveIntelRadios", []]);

	    if (!isNull _nearIntelRadio) exitWith {
                [_nearIntelRadio] call fnc_openIntelUI;
            };

            if (_nearTerminal) exitWith {
                ["sandbagTerminal_1"] call fnc_openSandbagUI;
            };

            if (_nearCrateModule) exitWith {
                createDialog "ResupplySpawnDialog";
            };

        };

        false
    }];
};

missionNamespace setVariable ["ui_bind6Key_radioOnly", ui_bind6Key_radioOnly];

fnc_startModuleGhost = {
    params ["_class", "_cost", "_structureType"];

    fob_buildConfirmed = false;
    fob_buildCancelled = false;

    [_class] call fob_createGhost;
    [] call fob_bindBuildControls;

    ["Place module: Q/E rotate, R/F raise/lower, SPACE confirm, ESC cancel"] 
        remoteExec ["hint", player];

    [_class, _cost, _structureType] spawn {
        params ["_class", "_cost", "_structureType"];

        while { !isNull fob_ghostObj && !fob_buildConfirmed && !fob_buildCancelled } do {

            private _aimPos = [] call fob_getAimPos;

            if (count _aimPos == 0) then {
                fob_ghostObj hideObject true;
            } else {
                fob_ghostObj hideObject false;
                fob_ghostObj setPosATL [
                    _aimPos select 0,
                    _aimPos select 1,
                    (_aimPos select 2) + fob_ghostHeightOffset
                ];
                fob_ghostObj setDir fob_ghostAngle;
            };

            sleep 0.05;
        };

        if (fob_buildConfirmed) then {
            private _finalPos = getPosATL fob_ghostObj;

            [_structureType, _finalPos, fob_ghostAngle] 
                remoteExec ["fnc_serverPlaceModule", 2];
        };

        [] call fob_cleanupGhost;
    };
};

fnc_startModulePlacement = {
    params ["_structureType"];

    private _terminal = missionNamespace getVariable ["activeTerminal", objNull];
    if (isNull _terminal) exitWith {};

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

    [_class, _cost, _structureType] call fnc_startModuleGhost;
};

fnc_openSandbagUI = {
    params ["_terminalID"];

    private _terminal = missionNamespace getVariable [_terminalID, objNull];
    if (isNull _terminal) exitWith {};

    missionNamespace setVariable ["activeTerminal", _terminal];

    createDialog "SandbagDialog";
    waitUntil {dialog};

    private _supply = _terminal getVariable ["sandbagSupply", 0];
    ctrlSetText [1001, format ["Supply Dump: %1", _supply]];
};

fnc_openIntelUI = {
    params ["_radio"];

    if (isNull _radio) exitWith {};

    missionNamespace setVariable ["activeIntelRadio", _radio];

    createDialog "IntelDialog";
    waitUntil { dialog };
};

fnc_clientCheckIntel = {
    private _radio = missionNamespace getVariable ["activeIntelRadio", objNull];
    if (isNull _radio) exitWith {};

    [_radio, player] remoteExec ["fnc_serverCheckIntel", 2];
};

missionNamespace setVariable ["fnc_clientCheckIntel", fnc_clientCheckIntel];

fnc_buildStructure = {
    params ["_structureType"];

    private _terminal = missionNamespace getVariable ["activeTerminal", objNull];
    if (isNull _terminal) exitWith {};

    [_structureType] call fnc_startModulePlacement;
};

fnc_clientIntelResult = {
    params ["_result", "_playerName"];

    switch (_result) do {

        case "success": {
            [
                "YesIntel",
                [format ["%1 has recovered enemy intel!", _playerName]]
            ] remoteExec ["BIS_fnc_showNotification", 0];
        };

        case "fail": {
            [
                "NoIntel",
                ["No intel found at this radio."]
            ] remoteExec ["BIS_fnc_showNotification", player];
        };

        case "already": {
            [
                "NoIntel",
                ["This radio has already been checked."]
            ] remoteExec ["BIS_fnc_showNotification", player];
        };
    };
};

missionNamespace setVariable ["fnc_clientIntelResult", fnc_clientIntelResult];



