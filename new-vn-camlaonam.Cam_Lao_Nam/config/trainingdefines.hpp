class TraitAssignmentDialog {
    idd = 9300;
    movingEnable = false;
    enableSimulation = true;

    class controlsBackground {
        class Background : RscText {
            idc = -1;
            x = 0.35; y = 0.35;
            w = 0.3; h = 0.35;
            colorBackground[] = { 0, 0, 0, 0.7 };
        };
    };

    class controls {
        class Title : RscText {
            idc = -1;
            text = "Trait Assignment";
            x = 0.35; y = 0.35;
            w = 0.3; h = 0.05;
            colorText[] = { 1, 1, 1, 1 };
        };

        #define BUTTON_W 0.26
        #define BUTTON_H 0.05
        #define BUTTON_X 0.37
        #define START_Y 0.41
        #define SPACING_Y 0.06

        class ButtonMedic : RscButton {
            idc = 9301;
            text = "Assign Medic";
            x = BUTTON_X; y = START_Y + (0 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""Medic"", false, ""Medic Role Assigned"", ""RoleMedicIcon""] call fnc_assignTrait; closeDialog 0;";
        };

        class ButtonEngineer : RscButton {
            idc = 9302;
            text = "Assign Engineer";
            x = BUTTON_X; y = START_Y + (1 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""Engineer"", false, ""Engineer Role Assigned"", ""RoleEngineerIcon""] call fnc_assignTrait; closeDialog 0;";
        };

        class ButtonConstruction : RscButton {
            idc = 9303;
            text = "Assign Construction";
            x = BUTTON_X; y = START_Y + (2 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""Construction"", true, ""Construction Role Assigned"", ""RoleConstructionIcon""] call fnc_assignTrait; closeDialog 0;";
        };

        class ButtonRecon : RscButton {
            idc = 9304;
            text = "Assign Recon";
            x = BUTTON_X; y = START_Y + (3 * SPACING_Y);
            w = BUTTON_W; h = BUTTON_H;
            action = "[""Recon"", true, ""Recon Role Assigned"", ""ReconUpdate""] call fnc_assignTrait; closeDialog 0;";
        };
    };
};
