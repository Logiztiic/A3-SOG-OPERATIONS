if (!hasInterface) exitWith {};


ui_bindKey5 = {
    waitUntil { !isNull findDisplay 46 };

    private _fireBlockHandler = -1;

    (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_display", "_keyCode"];

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

        ) exitWith { false };

        if (_keyCode isEqualTo 6) then {
            if (isNil "ui_fireBlockHandler") then {
                ui_fireBlockHandler = (findDisplay 46) displayAddEventHandler ["KeyDown", {
                    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
                    if (_key in [1, 57]) then { true } else { false }; // LMB and space
                }];
            };

            (findDisplay 46) createDisplay "FobExtrasDialog";

            ui_dialogMonitor = [] spawn {
                waitUntil { isNull findDisplay 9050 };
                if (!isNil "ui_fireBlockHandler") then {
                    (findDisplay 46) displayRemoveEventHandler ["KeyDown", ui_fireBlockHandler];
                    ui_fireBlockHandler = nil;
                };
            };
        };

        false
    }];
};

missionNamespace setVariable ["ui_bindKey5", ui_bindKey5];

fnc_toggleEarplugs = {
    if (isNil "earplugsActive") then { earplugsActive = false };

    earplugsActive = !earplugsActive;

    if (earplugsActive) then {
        1 fadeSound 0.2;
    } else {
        1 fadeSound 1;
    };
};

fnc_handleReconButton = {
    if (player getUnitTrait "Recon") then {
        [player] remoteExec ["fnc_spotEnemyAssets", 2];
    } else {
        [ "ReconUpdate", ["Recon Role Required."]] remoteExec ["BIS_fnc_showNotification", player];

    };
};