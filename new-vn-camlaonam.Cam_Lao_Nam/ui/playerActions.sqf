if (!hasInterface) exitWith {};


fnc_spawnCrate = {
    params ["_class", "_message"];

    private _spawnPoints = [
        [16197,7058.98,0],
        [15807.4,7248.89,0],
        [16543.3,7676.99,0]  
    ];

    private _nearestPos = [_spawnPoints, player] call BIS_fnc_nearestPosition;
    [_class, _nearestPos] remoteExec ["fnc_spawnCrate_server", 2];
};

fnc_assignTrait = {
    params ["_trait", "_isCustom", "_message", "_trainingtype"];

    {
        private _name = _x select 0;
        private _custom = _x select 1;
        if (_custom) then {
            player setUnitTrait [_name, false, true];
        } else {
            player setUnitTrait [_name, false];
        };
    } forEach [
        ["Medic", false],
        ["Engineer", false],
        ["Construction", true],
        ["Recon", true]
    ];

    if (_isCustom) then {
        player setUnitTrait [_trait, true, true];
    } else {
        player setUnitTrait [_trait, true];
    };

    player setVariable ["assignedTrait", [_trait, _isCustom], true];

    [_trainingtype, [_message]] remoteExec ["BIS_fnc_showNotification", player];
};

ui_bind6Key = {
    waitUntil { !isNull findDisplay 46 };

    (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_display", "_keyCode"];

        if (_keyCode isEqualTo 7) then {
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

            private _supplyStations = [
                Supply_Officer_Ammo_1,
                Supply_Officer_Ammo_2,
                Supply_Officer_Ammo_3
            ];

            private _nearSupply = {_x distance player < 2} count _supplyStations > 0;

            private _trainingStations = [
                Training_Officer_1,
                Training_Officer_2,
                Training_Officer_3,
                Training_Officer_4
            ];

            private _nearTrainer = {_x distance player < 2} count _trainingStations > 0;

            if (_nearSupply) exitWith { createDialog "CrateSpawnDialog" };
            if (_nearTrainer) exitWith { createDialog "TraitAssignmentDialog" };
        };

        false
    }];
};

missionNamespace setVariable ["ui_bind6Key", ui_bind6Key];
