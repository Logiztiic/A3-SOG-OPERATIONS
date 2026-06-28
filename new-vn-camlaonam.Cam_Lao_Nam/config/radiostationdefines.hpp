class SandbagDialog {
    idd = 9400;
    movingEnable = false;
    enableSimulation = true;

    class Controls {
        class Background : RscText {
            idc = -1;
            x = 0.18; y = 0.12;
            w = 0.70; h = 0.58;
            colorBackground[] = { 0, 0, 0, 0.7 };
        };

        class InfoText : RscText {
            idc = 1001;
            text = "Supplies: 0";
            x = 0.30; y = 0.14;
            w = 0.40; h = 0.06;
            sizeEx = 0.05;
        };

        class BuildVehRefuelMod : RscButton {
            idc = 2001;
            text = "Vehicle Refuel Module (150)";
            x = 0.22; y = 0.22;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['VehRefuel'] call fnc_buildStructure;";
        };

        class BuildVehRearmMod : RscButton {
            idc = 2002;
            text = "Vehicle Ammo Module (500)";
            x = 0.22; y = 0.31;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['VehRearm'] call fnc_buildStructure;";
        };

        class BuildVehRepairMod : RscButton {
            idc = 2003;
            text = "Vehicle Repair Module (300)";
            x = 0.22; y = 0.40;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['VehRepair'] call fnc_buildStructure;";
        };

        class BuildRespawnPoint : RscButton {
            idc = 2004;
            text = "Ammo Crate Module (500)";
            x = 0.22; y = 0.49;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['CrateModule'] call fnc_buildStructure;";
        };

        class ResupplyButton : RscButton {
            idc = 2005;
            text = "Resupply this Station";
            x = 0.52; y = 0.22;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; [missionNamespace getVariable 'sandbagTerminal_1'] remoteExec ['fnc_resupplyTerminal', 2];";
        };

        class ShutdownButton : RscButton {
            idc = 2006;
            text = "Teardown this Station";
            x = 0.52; y = 0.31;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; createDialog 'ShutdownConfirmDialog';";
        };

        class ExportCrateButton : RscButton {
            idc = 2007;
            text = "Export All Supplies";
            x = 0.52; y = 0.40;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; [missionNamespace getVariable 'sandbagTerminal_1'] remoteExec ['fnc_exportSandbagsToCrate', 2];";
        };

        class BuildEmpty : RscButton {
            idc = 2008;
            text = "Build Empty (X)";
            x = 0.52; y = 0.49;
            w = 0.27; h = 0.06;
            action = "closeDialog 0;";
        };
    };
};

class ShutdownConfirmDialog {
    idd = 9600;
    movingEnable = false;
    enableSimulation = true;

    class Controls {
        class Background : RscText {
            idc = -1;
            x = 0.25; y = 0.25;
            w = 0.5; h = 0.2;
            colorBackground[] = { 0, 0, 0, 0.7 };
        };

        class ConfirmText : RscText {
            idc = 1401;
            text = "Confirm ? This cannot be undone.";
            x = 0.3; y = 0.3;
            w = 0.4; h = 0.05;
            sizeEx = 0.04;
        };

        class ConfirmButton : RscButton {
            idc = 1402;
            text = "Confirm";
            x = 0.3; y = 0.36;
            w = 0.18; h = 0.05;
            action = "[missionNamespace getVariable 'sandbagTerminal_1', player] remoteExec ['fnc_shutdownStation', 2]; closeDialog 0;";
        };

        class CancelButton : RscButton {
            idc = 1403;
            text = "Cancel";
            x = 0.52; y = 0.36;
            w = 0.18; h = 0.05;
            action = "closeDialog 0;";
        };
    };
};

class ResupplySpawnDialog {
    idd = 9700;
    movingEnable = false;
    enableSimulation = true;

    class Controls {
        class Background : RscText {
            idc = -1;
            x = 0.18; y = 0.12;
            w = 0.70; h = 0.58;
            colorBackground[] = { 0, 0, 0, 0.7 };
        };

        class InfoText : RscText {
            idc = 1001;
            text = "Supply Dump Options";
            x = 0.30; y = 0.14;
            w = 0.40; h = 0.06;
            sizeEx = 0.06;
        };

        class Crate1 : RscButton {
            idc = 2101;
            text = "Basic Mags Crate (120)";
            x = 0.22; y = 0.22;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['MagsCrate'] remoteExec ['fnc_spawnCrateFromModule', 2];";
        };

        class Crate2 : RscButton {
            idc = 2102;
            text = "Medical Crate (90)";
            x = 0.22; y = 0.31;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['MedicalCrate'] remoteExec ['fnc_spawnCrateFromModule', 2];";
        };

        class Crate3 : RscButton {
            idc = 2103;
            text = "Light Ammo Crate (60)";
            x = 0.22; y = 0.40;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['AmmoLight'] remoteExec ['fnc_spawnCrateFromModule', 2];";
        };

        class Crate4 : RscButton {
            idc = 2104;
            text = "Explosives Crate (250)";
            x = 0.22; y = 0.49;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['GrenadeCrate'] remoteExec ['fnc_spawnCrateFromModule', 2];";
        };

        class Crate5 : RscButton {
            idc = 2105;
            text = "M60 High Crate (450)";
            x = 0.52; y = 0.22;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['M60Crate'] remoteExec ['fnc_spawnCrateFromModule', 2];";
        };

        class Crate6 : RscButton {
            idc = 2106;
            text = "Heavy Ammo Crate (75)";
            x = 0.52; y = 0.31;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['HeavyAmmo'] remoteExec ['fnc_spawnCrateFromModule', 2];";
        };

        class Crate7 : RscButton {
            idc = 2107;
            text = "MK18 GL Crate (650)";
            x = 0.52; y = 0.40;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['Mk18Crate'] remoteExec ['fnc_spawnCrateFromModule', 2];";
        };

        class Crate8 : RscButton {
            idc = 2108;
            text = "Small Ammo Crate (50)";
            x = 0.52; y = 0.49;
            w = 0.27; h = 0.06;
            action = "closeDialog 0; ['SmallCrate'] remoteExec ['fnc_spawnCrateFromModule', 2];";
        };
    };
};
