fnc_initInfoAndVehicleLock = {
    [] spawn {
        sleep 2;
        missionNamespace setVariable ["InfoPageIndex", 0];
        createDialog "InfoDialog";
        ["init"] call (missionNamespace getVariable "fnc_switchInfoPage");
    };

    [] spawn {
        waitUntil {
            !isNil {missionNamespace getVariable "trackedVehicles"} &&
            {count (missionNamespace getVariable "trackedVehicles") > 0}
        };

        private _allowedNames = [
            "CayuseLocked_1",
            "CayuseLocked_2",
            "CayuseLocked_3"
        ];

        while {true} do {
            [_allowedNames] call (missionNamespace getVariable "fnc_lockNamedVehicles");
            sleep 5;
        };
    };
};

missionNamespace setVariable ["fnc_initInfoAndVehicleLock", fnc_initInfoAndVehicleLock];