class InfoDialog {
    idd = 9000;
    movingEnable = 0;
    duration = 99999;
    fadein = 0;
    fadeout = 0;
    name = "InfoDialog";
    onLoad = "uiNamespace setVariable ['InfoDialog', _this select 0];";

    class controls {
        class Background : RscText {
            idc = -1;
            x = 0.2; y = 0.1;
            w = 0.6; h = 0.75;
            colorBackground[] = { 0, 0, 0, 0.8 };
        };

        class InfoText : RscStructuredText {
            idc = 9001;
            x = 0.21; y = 0.12;
            w = 0.58; h = 0.6;
            text = "";
            size = 0.035;
        };

        class BtnExit : RscButton {
            idc = 9004;
            text = "X";
            x = 0.75; y = 0.11;
            w = 0.04; h = 0.04;
            action = "closeDialog 0;";
        };

        class BtnPrev : RscButton {
            idc = 9003;
            text = "Prev Page";
            x = 0.22; y = 0.78;
            w = 0.12; h = 0.05;
            action = "['prev'] call fnc_switchInfoPage;";
        };

        class BtnNext : RscButton {
            idc = 9002;
            text = "Next Page";
            x = 0.66; y = 0.78;
            w = 0.12; h = 0.05;
            action = "['next'] call fnc_switchInfoPage;";
        };
    };
};