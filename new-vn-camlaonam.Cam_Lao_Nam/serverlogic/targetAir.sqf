missionNamespace setVariable ["fnc_autoTargetAA", {
    params ["_aaGun"];

    if (isNull _aaGun || {!alive _aaGun}) exitWith {};

    private _gunner = gunner _aaGun;
    if (!isNull _gunner) then {
        _gunner setSkill ["spotDistance", 1];
        _gunner setSkill ["spotTime", 1];
        _gunner setSkill ["aimingAccuracy", 0.8];
        _gunner setCombatMode "RED";
        _gunner setBehaviour "COMBAT";
    };

    [_aaGun] spawn {
        params ["_unit"];
        while {alive _unit} do {
            private _targets = allUnits select {
                alive _x &&
                {_x isKindOf "Helicopter"} &&
                {_x distance _unit < 1500} &&
                {side _x != side _unit}
            };

            if (count _targets > 0) then {
                private _target = _targets select 0;

                _unit reveal _target;
                _unit commandTarget _target;

                _unit doTarget _target;
                _unit doFire _target;
                _unit fireAtTarget _target;
            };

            sleep 5;
        };
    };
}];
