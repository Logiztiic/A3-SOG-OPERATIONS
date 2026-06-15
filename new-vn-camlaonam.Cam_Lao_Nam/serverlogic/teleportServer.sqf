missionNamespace setVariable ["fnc_teleportPlayer_server", {
    params ["_unit", "_pos"];
    if (!isNull _unit && {alive _unit}) then {
        _unit setPosATL _pos;
    };
}];
