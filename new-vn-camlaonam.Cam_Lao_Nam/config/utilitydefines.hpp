class FobExtrasDialog {
    idd = 9050;
    movingEnable = false;
    enableSimulation = false;
    onUnload = "if (!isNil 'ui_fireBlockHandler') then { (findDisplay 46) displayRemoveEventHandler ['KeyDown', ui_fireBlockHandler]; ui_fireBlockHandler = nil; };";

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
            text = "Utilities";
            x = 0.35;
            y = 0.35;
            w = 0.3;
            h = 0.05;
        };

        class EarplugButton : RscButton {
            idc = 9051;
            text = "Toggle Earplugs";
            x = 0.375;
            y = 0.41;
            w = 0.25;
            h = 0.07;
            action = "(findDisplay 9050) closeDisplay 1; [] call fnc_toggleEarplugs;";
        };

        class ReconButton : RscButton {
            idc = 9052;
            text = "Recon Scan";
            x = 0.375;
            y = 0.49;
            w = 0.25;
            h = 0.07;
            action = "(findDisplay 9050) closeDisplay 1; [] call fnc_handleReconButton;";
        };
    };
};