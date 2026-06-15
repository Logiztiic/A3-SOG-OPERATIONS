private _vehicleArray = [
    [objnull, [16447,7064.46,0.0419998], 180, "vn_b_air_oh6a_02", 10, -1, "CayuseLocked_1"],
    [objnull, [16475.6,7064.35,0.0419998], 180, "vn_b_air_oh6a_02", 10, -1, "CayuseLocked_2"],
    [objnull, [16503.8,7064.59,0.0423908], 180, "vn_b_air_oh6a_02", 10, -1, "CayuseLocked_3"],
    [objnull, [16531.4,7064.48,0.0423908], 180, "vn_b_air_oh6a_01", 10, -1, "CayuseUnlocked_1"],
    [objnull, [16132.4,7058.21,0], 180, "vn_b_air_ch34_01_01", 10, -1, "SeahorseUnlocked_1"],
    [objnull, [16075.6,7056.06,0], 180, "vn_b_air_ch34_01_01", 10, -1, "SeahorseUnlocked_2"],
    [objnull, [16104.8,7056.29,0], 180, "vn_b_air_uh1d_02_03", 10, -1, "HueyUnlocked_1"],
    [objnull, [15928.3,7056.1,0], 180, "vn_b_air_uh1d_02_03", 10, -1, "HueyUnlocked_2"],
    [objnull, [16011.4,7056.13,0], 180, "vn_b_air_uh1c_07_05", 10, -1, "HueyUnlocked_3"],
    [objnull, [15984.1,7056.44,0], 180, "vn_b_air_uh1c_07_05", 10, -1, "HueyUnlocked_4"],
    [objnull, [15899.7,7056.09,0], 180, "vn_b_air_uh1b_01_02", 10, -1, "HueyUnlocked_5"],
    [objnull, [15956.3,7056.8,0], 180, "vn_b_air_ch34_01_01", 10, -1, "SeahorseUnlocked_3"],
    [objnull, [15681.6,7232.78,0], 180, "vn_b_air_ch47_01_01", 10, -1, "ChinookUnlocked_1"],
    [objnull, [15747.7,7232.78,0], 180, "vn_b_air_ch47_01_01", 10, -1, "ChinookUnlocked_2"],
    [objnull, [16522.7,7665.79,0], 90, "vn_b_wheeled_m54_02", 10, -1, "AmTruckUnlocked_1"],
    [objnull, [16522.8,7672.88,0], 90, "vn_b_wheeled_m54_02", 10, -1, "AmTruckUnlocked_2"],
    [objnull, [16509.3,7681.84,0], 116, "vn_b_wheeled_m151_mg_03_mp", 10, -1, "ArmedJeepUnlocked_1"],
    [objnull, [16509.3,7686.65,0], 116, "vn_b_wheeled_m151_mg_03_mp", 10, -1, "ArmedJeepUnlocked_2"],
    [objnull, [16510.3,7692.16,0], 116, "vn_b_wheeled_m151_mg_03_mp", 10, -1, "ArmedJeepUnlocked_3"],
    [objnull, [16516,7696.18,0], 180, "vn_b_wheeled_m151_mg_04_mp", 10, -1, "ArmoredJeepUnlocked_1"],
    [objnull, [16604.9,7700.09,0], 265, "vn_b_wheeled_m54_01_usmc", 10, -1, "AmTruckUnlocked_3"],
    [objnull, [16605.2,7694.97,0], 265, "vn_b_wheeled_m54_01_usmc", 10, -1, "AmTruckUnlocked_4"],
    [objnull, [16605.8,7678.14,0], 270, "vn_b_armor_m113_acav_05", 10, -1, "ApcUnlocked_1"],
    [objnull, [16605.7,7672.34,0], 270, "vn_b_armor_m113_acav_04", 10, -1, "ApcUnlocked_2"],
    [objnull, [16605.9,7666.61,0], 270, "vn_b_armor_m113_acav_06", 10, -1, "ApcUnlocked_3"],
    [objnull, [16583.5,7651.66,0], 0, "vn_b_armor_m113_acav_01", 10, -1, "ApcUnlocked_4"],
    [objnull, [16577,7651.81,0], 0, "vn_b_armor_m113_acav_01", 10, -1, "ApcUnlocked_5"],
    [objnull, [16567.6,7634.86,0], 270, "vn_b_armor_m67_01_01", 10, -1, "FlameTankUnlocked_1"],
    [objnull, [16566.8,7627.1,0], 270, "vn_b_armor_m41_01_01", 10, -1, "M41TankUnlocked_1"],
    [objnull, [16567.4,7619.57,0], 270, "vn_b_armor_m41_01_01", 10, -1, "M41TankUnlocked_2"],
    [objnull, [15870,8064.46,2.934], 357, "vn_b_boat_11_01", 10, -1, "StabMK18Unlocked_1"],
    [objnull, [15881,8064.81,2.609], 358, "vn_b_boat_11_01", 10, -1, "StabMK18Unlocked_2"],
    [objnull, [15908.1,8068.39,2.962], 267, "vn_b_boat_12_02", 10, -1, "PBRBoatUnlocked_1"],
    [objnull, [15928.1,8067.63,4.983], 358, "vn_b_boat_12_04", 10, -1, "PBRBoatUnlocked_2"],
    [objnull, [15926.5,8117.04,7.211], 358, "vn_b_boat_13_01", 10, -1, "PBRBoatUnlocked_3"],
    [objnull, [15947.7,8134.61,3.857], 358, "vn_b_boat_06_01", 10, -1, "PTFBoatUnlocked_1"]
];
missionNamespace setVariable ["trackedVehicles", _vehicleArray];
publicVariable "trackedVehicles";


fnc_initVehicleSet = {
    private _vehicleArray = missionNamespace getVariable ["trackedVehicles", []];

    {
        private _entry   = _x;
        private _varName = _entry select 6;
        private _pos     = _entry select 1;
        private _dir     = _entry select 2;
        private _type    = _entry select 3;

        private _veh = createVehicle [_type, _pos, [], 0, "NONE"];
        _veh setDir _dir;
        _veh setPosATL (_pos vectorAdd [0, 0, 0.4]);

        missionNamespace setVariable [_varName, _veh];
        _entry set [0, _veh];
    } forEach _vehicleArray;

    publicVariable "trackedVehicles";
};

missionNamespace setVariable ["fnc_initVehicleSet", fnc_initVehicleSet];

fnc_respawnVehicle = {
    params ["_entry"];

    private _varName = _entry select 6;
    private _pos     = _entry select 1;
    private _dir     = _entry select 2;
    private _type    = _entry select 3;

    private _oldVeh = missionNamespace getVariable _varName;
    if (!isNull _oldVeh) then {
        deleteVehicle _oldVeh;
    };

    private _veh = createVehicle [_type, _pos, [], 0, "NONE"];
    _veh setDir _dir;
    _veh setPosATL (_pos vectorAdd [0, 0, 0.4]);

    missionNamespace setVariable [_varName, _veh];
    _entry set [0, _veh];
    _entry set [5, -1];

    publicVariable "trackedVehicles";
};

missionNamespace setVariable ["fnc_respawnVehicle", fnc_respawnVehicle];