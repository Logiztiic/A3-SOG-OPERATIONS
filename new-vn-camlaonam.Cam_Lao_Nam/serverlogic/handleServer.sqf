fnc_unitStartup = {
    if (isServer) then {
        private _startPosMap = createHashMap;

        {
            private _uid = getPlayerUID _x;
            if (!isNil "_uid" && {_uid != ""}) then {
                private _pos = getPosATL _x;
                _startPosMap set [_uid, _pos];
            };
        } forEach playableUnits;

        missionNamespace setVariable ["unitStartPositions", _startPosMap];
        publicVariable "unitStartPositions";
    };

    addMissionEventHandler ["PlayerDisconnected", {
        params ["_id", "_uid", "_name"];

        private _unit = _uid call BIS_fnc_getUnitByUID;
        if (!isNull _unit) then {
            deleteVehicle _unit;
        };
    }];

    addMissionEventHandler ["PlayerConnected", {
    	params ["_id", "_uid", "_name"];

    	private _radio = missionNamespace getVariable ["activeRadioStation", objNull];

    	if (!isNull _radio) then {
            [_radio] remoteExec ["fnc_updateStationMarker", _id];
    	};
    }];
};

missionNamespace setVariable ["fnc_unitStartup", fnc_unitStartup];
