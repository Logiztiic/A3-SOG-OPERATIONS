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
