class IntelDialog {
    idd = 9800;
    movingEnable = false;
    enableSimulation = true;

    class controlsBackground {
        class Background : RscText {
            idc = -1;
            x = 0.35;
            y = 0.35;
            w = 0.3;
            h = 0.25;
            colorBackground[] = { 0, 0, 0, 0.7 };
        };
    };

    class controls {

        class Title : RscText {
            idc = -1;
            text = "Intel Radio";
            x = 0.35;
            y = 0.35;
            w = 0.3;
            h = 0.05;
            colorText[] = { 1,1,1,1 };
        };

        class BtnClose : RscButton {
            idc = 9803;
            text = "X";
            x = 0.57;
            y = 0.355;
            w = 0.06;
            h = 0.045;
            action = "closeDialog 0;";
        };

        class BtnCheck : RscButton {
            idc = 9802;
            text = "Check for Intel";
            x = 0.37;
            y = 0.53;
            w = 0.26;
            h = 0.05;
            action = "[] call fnc_clientCheckIntel; closeDialog 0;";
        };
    };
};