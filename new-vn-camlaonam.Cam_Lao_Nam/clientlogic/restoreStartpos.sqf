fnc_restoreStartPos = {
    if (didJIP) then {
        private _startMap = missionNamespace getVariable ["unitStartPositions", createHashMap];
        private _uid = getPlayerUID player;
        private _startPos = _startMap get [_uid, getPosATL player];

        if (!isNil "_startPos") then {
            player setPosATL _startPos;
        } else {
            diag_log format ["[StartPos] No saved position for UID %1", _uid];
        };
    };
};

missionNamespace setVariable ["fnc_restoreStartPos", fnc_restoreStartPos];