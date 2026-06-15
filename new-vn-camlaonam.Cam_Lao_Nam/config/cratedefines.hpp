class CrateSpawnDialog {
    idd = 9200;
    movingEnable = false;
    enableSimulation = true;

    class controlsBackground {
        class Background : RscText {
            idc = -1;
            x = 0.35; y = 0.35;
            w = 0.3; h = 0.65;
            colorBackground[] = { 0, 0, 0, 0.7 };
        };
    };

    class controls {
        class Title : RscText {
            idc = -1;
            text = "Crate Spawn Menu";
            x = 0.35; y = 0.35;
            w = 0.3; h = 0.05;
            colorText[] = { 1, 1, 1, 1 };
        };

        #define BUTTON_W 0.26
        #define BUTTON_H 0.05
        #define BUTTON_X 0.37
        #define START_Y 0.41
        #define SPACING_Y 0.06

        class Button1 : RscButton {
            idc = 9201;
            text = "Spawn M60 Low Crate";
            x = BUTTON_X; y = START_Y + (0 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""vn_b_ammobox_wpn_07"", ""M60 Low Crate Spawned!""] call fnc_spawnCrate; closeDialog 0;";
        };

        class Button2 : RscButton {
            idc = 9202;
            text = "Spawn M60 High Crate";
            x = BUTTON_X; y = START_Y + (1 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""vn_b_ammobox_wpn_06"", ""M60 High Crate Spawned!""] call fnc_spawnCrate; closeDialog 0;";
        };

        class Button3 : RscButton {
            idc = 9203;
            text = "Spawn M2 Low Crate";
            x = BUTTON_X; y = START_Y + (2 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""vn_b_ammobox_wpn_02"", ""M2 Low Crate Spawned!""] call fnc_spawnCrate; closeDialog 0;";
        };

        class Button4 : RscButton {
            idc = 9204;
            text = "Spawn M2 High Crate";
            x = BUTTON_X; y = START_Y + (3 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""vn_b_ammobox_wpn_01"", ""M2 High Crate Spawned!""] call fnc_spawnCrate; closeDialog 0;";
        };

        class Button5 : RscButton {
            idc = 9205;
            text = "Spawn Ammo Light";
            x = BUTTON_X; y = START_Y + (4 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""vn_b_ammobox_supply_13"", ""Light Ammo Crate Spawned!""] call fnc_spawnCrate; closeDialog 0;";
        };

        class Button6 : RscButton {
            idc = 9206;
            text = "Spawn Ammo Mags";
            x = BUTTON_X; y = START_Y + (5 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""vn_b_ammobox_full_02"", ""Mags Crate Spawned!""] call fnc_spawnCrate; closeDialog 0;";
        };

        class Button7 : RscButton {
            idc = 9207;
            text = "Spawn Ammo Grenades";
            x = BUTTON_X; y = START_Y + (6 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""vn_b_ammobox_full_10"", ""Grenades Crate Spawned!""] call fnc_spawnCrate; closeDialog 0;";
        };

        class Button8 : RscButton {
            idc = 9208;
            text = "Spawn Medical Crate";
            x = BUTTON_X; y = START_Y + (7 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""vn_b_ammobox_supply_03"", ""Medical Crate Spawned!""] call fnc_spawnCrate; closeDialog 0;";
        };

        class Button9 : RscButton {
            idc = 9209;
            text = "Spawn Supply Crate";
            x = BUTTON_X; y = START_Y + (8 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""vn_b_ammobox_supply_10"", ""Building Crate Spawned!""] call fnc_spawnCrate; closeDialog 0;";
        };
    };
};