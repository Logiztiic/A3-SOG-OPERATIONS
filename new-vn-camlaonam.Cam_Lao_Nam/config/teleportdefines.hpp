class TeleportDialog {
    idd = 9100;
    movingEnable = false;
    enableSimulation = true;

    class controlsBackground {
        class Background : RscText {
            idc = -1;
            x = 0.35;
            y = 0.35;
            w = 0.3;
            h = 0.38;
            colorBackground[] = { 0, 0, 0, 0.7 };
        };
    };

    class controls {
        class Title : RscText {
            idc = -1;
            text = "Teleport Menu";
            x = 0.35;
            y = 0.35;
            w = 0.3;
            h = 0.05;
            colorText[] = { 1, 1, 1, 1 };
        };

        #define BUTTON_W 0.26
        #define BUTTON_H 0.05
        #define BUTTON_X 0.37
        #define START_Y 0.41
        #define SPACING_Y 0.06

        class telbutton1 : RscButton {
            idc = 9101;
            text = "Main Area Pleiku";
            x = BUTTON_X;
            y = START_Y + (0 * SPACING_Y);
            w = BUTTON_W;
            h = BUTTON_H;
            action = "[0] call fnc_teleportPlayer; closeDialog 0;";
        };

        class telbutton2 : RscButton {
            idc = 9102;
            text = "Vehicles Pleiku";
            x = BUTTON_X;
            y = START_Y + (1 * SPACING_Y);
            w = BUTTON_W;
            h = BUTTON_H;
            action = "[1] call fnc_teleportPlayer; closeDialog 0;";
        };

        class telbutton3 : RscButton {
            idc = 9103;
            text = "West Area Pleiku";
            x = BUTTON_X;
            y = START_Y + (2 * SPACING_Y);
            w = BUTTON_W;
            h = BUTTON_H;
            action = "[2] call fnc_teleportPlayer; closeDialog 0;";
        };

        class telbutton4 : RscButton {
            idc = 9104;
            text = "North Area Pleiku";
            x = BUTTON_X;
            y = START_Y + (3 * SPACING_Y);
            w = BUTTON_W;
            h = BUTTON_H;
            action = "[3] call fnc_teleportPlayer; closeDialog 0;";
        };

        class telbutton5 : RscButton {
            idc = 9105;
            text = "Boats Area Pleiku";
            x = BUTTON_X;
            y = START_Y + (4 * SPACING_Y);
            w = BUTTON_W;
            h = BUTTON_H;
            action = "[4] call fnc_teleportPlayer; closeDialog 0;";
        };
    };
};
