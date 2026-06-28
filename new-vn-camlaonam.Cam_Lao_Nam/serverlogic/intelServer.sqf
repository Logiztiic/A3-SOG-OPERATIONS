fnc_serverCheckIntel = {
    params ["_radio", "_player"];

    if (isNull _radio || {isNull _player}) exitWith {};

    private _isIntel = _radio getVariable ["isIntelRadio", false];
    private _checked = _radio getVariable ["intelChecked", false];
    private _name = name _player;

    if (_checked) exitWith {
        ["already", _name] remoteExec ["fnc_clientIntelResult", _player];
    };

    _radio setVariable ["intelChecked", true, true];

    if (_isIntel) then {
        missionNamespace setVariable ["IntelFound", true];

        ["task_findIntel"] call (missionNamespace getVariable "fnc_completeTask");

        ["success", _name] remoteExec ["fnc_clientIntelResult", 0];
    }
    else {
        ["fail", _name] remoteExec ["fnc_clientIntelResult", _player];
    };
};

missionNamespace setVariable ["fnc_serverCheckIntel", fnc_serverCheckIntel];

fnc_server_startSaboteurTracking = {
    params ["_requester"];

    if (!isServer) exitWith {};

    private _radio      = missionNamespace getVariable ["activeIntelRadio", objNull];
    private _intelFound = missionNamespace getVariable ["IntelFound", false];
    private _allRadios  = missionNamespace getVariable ["ActiveIntelRadios", []];

    if (isNull _radio) exitWith {
        ["NoIntel", ["You must use the radio that contains the intel."]] 
            remoteExec ["BIS_fnc_showNotification", _requester];
    };

    if (!_intelFound) exitWith {
        ["NoIntel", ["This radio does not contain interceptable intel."]] 
            remoteExec ["BIS_fnc_showNotification", _requester];
    };

    private _unchecked = _allRadios select { !(_x getVariable ["intelChecked", false]) };

    if (count _unchecked > 0) exitWith {
        ["NoIntel", ["All radios in the AO must be checked before intercepting enemy comms."]] 
            remoteExec ["BIS_fnc_showNotification", _requester];
    };

    private _sabUnits = missionNamespace getVariable ["ActiveSaboteurUnits", []];
    _sabUnits = _sabUnits select { alive _x };

    if (count _sabUnits == 0) exitWith {
        ["NoIntel", ["No active saboteur teams detected."]] 
            remoteExec ["BIS_fnc_showNotification", _requester];
    };

    private _thread = missionNamespace getVariable ["SaboteurMarkerThread", scriptNull];
    if (!isNull _thread) exitWith {
        ["NoIntel", ["Comms already intercepted — tracking active."]] 
            remoteExec ["BIS_fnc_showNotification", _requester];
    };

    ["YesIntel", ["Intercepting enemy communications..."]] 
        remoteExec ["BIS_fnc_showNotification", _requester];

    private _newThread = [] spawn {
        private _markers = createHashMap;

        while {true} do {
            private _sabUnits = missionNamespace getVariable ["ActiveSaboteurUnits", []];
            _sabUnits = _sabUnits select { alive _x && {leader _x isEqualTo _x} };

            {
                private _unit = _x;
                private _uid  = str _unit;

                if (isNil {_markers get _uid}) then {
                    private _mName = format ["sab_%1", diag_tickTime + random 9999];
                    private _m = createMarker [_mName, getPosATL _unit];
                    _m setMarkerType "vn_flag_pavn";
                    _m setMarkerText "Saboteur";

                    _markers set [_uid, _m];
                };

                private _m = _markers get _uid;
                _m setMarkerPos (getPosATL _unit);
            } forEach _sabUnits;

            {
                private _uid = _x;
                private _m   = _markers get _uid;

                private _alive = _sabUnits findIf { str _x == _uid } != -1;

                if (!_alive) then {
                    deleteMarker _m;
                    _markers deleteAt _uid;
                };
            } forEach (keys _markers);

            sleep 1;
        };
    };

    missionNamespace setVariable ["SaboteurMarkerThread", _newThread];
};

missionNamespace setVariable ["fnc_server_startSaboteurTracking", fnc_server_startSaboteurTracking];


