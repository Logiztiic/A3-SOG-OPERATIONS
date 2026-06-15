fnc_setupPlayerHandlers = {
    params ["_unit"];

    _unit addEventHandler ["Killed", {
        params ["_unit", "_killer"];
        private _uid = getPlayerUID _unit;
        private _key = format ["loadout_%1", _uid];
        private _loadout = getUnitLoadout _unit;

        missionNamespace setVariable [_key, _loadout];
    }];

    _unit addEventHandler ["Respawn", {
        params ["_unit", "_corpse"];

        private _uid = getPlayerUID _unit;
        private _key = format ["loadout_%1", _uid];
        private _loadout = missionNamespace getVariable _key;

        if (!isNil "_loadout") then {
            _unit setUnitLoadout _loadout;
        };

        private _traitData = _unit getVariable ["assignedTrait", []];
        if (count _traitData == 2) then {
            private _trait = _traitData select 0;
            private _isCustom = _traitData select 1;

            if (_isCustom) then {
                _unit setUnitTrait [_trait, true, true];
            } else {
                _unit setUnitTrait [_trait, true];
            };
        };
    }];
};

missionNamespace setVariable ["fnc_setupPlayerHandlers", fnc_setupPlayerHandlers];

fnc_lockNamedVehicles = {
    params ["_vehicleNames"];

    private _vehicleArray = missionNamespace getVariable ["trackedVehicles", []];

    {
        private _vehName = _x;

        private _matched = _vehicleArray select {
            (_x select 6) == _vehName
        };

        if (count _matched > 0) then {
            private _veh = _matched select 0 select 0;

            if (!isNull _veh) then {
                private _alreadyTagged = _veh getVariable ["handlerAssigned", false];

                if (!_alreadyTagged) then {
                    _veh setVariable ["handlerAssigned", true];

                    _veh addEventHandler ["GetIn", {
                        private _vehicle = _this select 0;

                        private _traitData = player getVariable ["assignedTrait", []];
                        private _traitName = if (count _traitData > 0) then { _traitData select 0 } else { "" };
                        private _hasTrait = (_traitName == "Authvehicles") || { player getUnitTrait "Authvehicles" };

                        if (!_hasTrait) then {
                            player action ["getOut", _vehicle];
                            ["AccessDenied", ["You lack vehicle clearance for this vehicle."]] remoteExec ["BIS_fnc_showNotification", player];
                        };
                    }];

                    {
                        private _crewMember = _x;
                        if (_crewMember == player) then {
                            private _traitData = player getVariable ["assignedTrait", []];
                            private _traitName = if (count _traitData > 0) then { _traitData select 0 } else { "" };
                            private _hasTrait = (_traitName == "Authvehicles") || { player getUnitTrait "Authvehicles" };

                            if (!_hasTrait) then {
                                player action ["getOut", _veh];
                                ["AccessDenied", ["You were already inside without clearance."]] remoteExec ["BIS_fnc_showNotification", player];
                            };
                        };
                    } forEach crew _veh;
                };
            };
        };
    } forEach _vehicleNames;
};

missionNamespace setVariable ["fnc_lockNamedVehicles", fnc_lockNamedVehicles];