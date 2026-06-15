fnc_applyUIDTraits = {
    params ["_unit"];

    private _uid = getPlayerUID _unit;
    private _traitMap = [
        ["76561198832407081", "artillery"]
    ];

    private _traits = [];

    {
        if (_x select 0 == _uid) then {
            _traits pushBack (_x select 1);
        };
    } forEach _traitMap;

    {
        switch (_x) do {
            case "artillery":    { _unit setUnitTrait ["vn_artillery", true, true]; };
            case "medic":        { _unit setUnitTrait ["Medic", true]; };
            case "engineer":     { _unit setUnitTrait ["Engineer", true]; };
            case "construction": { _unit setUnitTrait ["Construction", true, true]; };
            case "recon":        { _unit setUnitTrait ["Recon", true, true]; };
            case "vehicleauth":  { _unit setUnitTrait ["AuthVehicles", true, true]; };
        };
    } forEach _traits;

    private _traitMapGlobal = missionNamespace getVariable ["assignedTraits", createHashMap];
    _traitMapGlobal set [_uid, _traits];
    missionNamespace setVariable ["assignedTraits", _traitMapGlobal];
};