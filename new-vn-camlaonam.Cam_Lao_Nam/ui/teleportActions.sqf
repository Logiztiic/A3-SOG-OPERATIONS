if (!hasInterface) exitWith {};


fnc_teleportPlayer = {
    params ["_index"];

    private _locations = [
        [16128.6,7136.73,0], // Main Area
        [16558.6,7673.54,0], // Vehicles
        [15718.9,7171.2,0], // West Area
        [15856.2,7508.61,0], // North Area
        [15910.6,8009.67,0]  // Boats Area
    ];

    if (_index < 0 || _index >= count _locations) exitWith {};

    private _targetPos = _locations select _index;

    [player, _targetPos] remoteExec ["fnc_teleportPlayer_server", 2];
};

ui_bindTeleportKey = {
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

            private _stations = [
                TeleportSign_1,
                TeleportSign_2,
                TeleportSign_3,
                TeleportSign_4,
                TeleportSign_5
            ];

            private _nearby = false;
            {
                if (player distance _x < 2) exitWith { _nearby = true };
            } forEach _stations;

            if (_nearby) then {
                createDialog "TeleportDialog";
            };
        };

        false
    }];
};

missionNamespace setVariable ["ui_bindTeleportKey", ui_bindTeleportKey];

