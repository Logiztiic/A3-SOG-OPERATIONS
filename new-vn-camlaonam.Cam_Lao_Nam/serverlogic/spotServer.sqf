fnc_spotEnemyAssets = {
    params ["_caller"];

    private _assetMap = [
        ["vn_o_nva_65_static_zgu1_01", ["AA", "o_antiair"]],
        ["vn_o_nva_65_static_zpu4",    ["AA", "o_antiair"]],
        ["vn_o_nva_65_static_mortar_type63", ["Artillery", "o_art"]],
        ["vn_o_nva_65_static_mortar_type53", ["Artillery", "o_art"]]
    ];

    private _existingMarkers = missionNamespace getVariable ["reconMarkers", []];
    private _updatedMarkers = +_existingMarkers;

    private _foundAny = false;

    {
        private _asset = _x;
        private _assetPos = getPos _asset;
        private _distance = _caller distance _asset;
        private _type = typeOf _asset;

        private _entryIndex = _assetMap findIf { _x select 0 == _type };

        if (
            alive _asset &&
            side _asset != side _caller &&
            {_entryIndex != -1} &&
            {_distance <= 400}
        ) then {
            private _alreadyMarked = false;

            {
                if (getMarkerPos _x distance _assetPos < 5) exitWith { _alreadyMarked = true };
            } forEach _existingMarkers;

            if (!_alreadyMarked) then {
                private _label = (_assetMap select _entryIndex) select 1 select 0;
                private _icon  = (_assetMap select _entryIndex) select 1 select 1;

                private _markerName = format ["reconAsset_%1", diag_tickTime + random 1000];
                private _marker = createMarker [_markerName, _assetPos];
                _marker setMarkerType _icon;
                _marker setMarkerText format ["%1", _label];

                _updatedMarkers pushBack _markerName;
                _foundAny = true;

                if (!isNull _caller) then {
                    [ "ReconUpdate", ["enemy asset marked on map."]] remoteExec ["BIS_fnc_showNotification", _caller];
                };
            };
        };
    } count (allUnits + vehicles);

    missionNamespace setVariable ["reconMarkers", _updatedMarkers];

    if (!_foundAny && {!isNull _caller}) then {
        [ "ReconUpdate", ["no enemy assets spotted within 400m."]] remoteExec ["BIS_fnc_showNotification", _caller];
    };
};

missionNamespace setVariable ["fnc_spotEnemyAssets", fnc_spotEnemyAssets];