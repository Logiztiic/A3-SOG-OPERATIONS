#define CT_STRUCTURED_TEXT 13
#define ST_LEFT 0
#define ST_CENTER 2
#define ST_RIGHT 1
#define ST_MULTI 16

class RscText {
    type = 0;
    idc = -1;
    colorBackground[] = { 0, 0, 0, 0 };
    colorText[] = { 1, 1, 1, 1 };
    text = "";
    fixedWidth = 0;
    x = 0;
    y = 0;
    w = 0.3;
    h = 0.05;
    style = 0;
    shadow = 1;
    font = "PuristaMedium";
    sizeEx = 0.04;
};

class RscButton {
    type = 1;
    text = "";
    colorText[] = { 1, 1, 1, 1 };
    colorDisabled[] = { 0.4, 0.4, 0.4, 1 };
    colorBackground[] = { 0.2, 0.2, 0.2, 1 };
    colorBackgroundDisabled[] = { 0.2, 0.2, 0.2, 0.5 };
    colorBackgroundActive[] = { 0.3, 0.3, 0.3, 1 };
    colorFocused[] = { 0.3, 0.3, 0.3, 1 };
    colorShadow[] = { 0, 0, 0, 1 };
    colorBorder[] = { 0, 0, 0, 1 };
    soundEnter[] = { "", 0.09, 1 };
    soundPush[] = { "", 0.09, 1 };
    soundClick[] = { "", 0.09, 1 };
    soundEscape[] = { "", 0.09, 1 };
    style = 2;
    x = 0;
    y = 0;
    w = 0.3;
    h = 0.05;
    shadow = 2;
    font = "PuristaMedium";
    sizeEx = 0.035;
    offsetX = 0.003;
    offsetY = 0.003;
    offsetPressedX = 0.002;
    offsetPressedY = 0.002;
    borderSize = 0;
};

class RscStructuredText {
    type = CT_STRUCTURED_TEXT;
    idc = -1;
    style = ST_LEFT;
    x = 0;
    y = 0;
    w = 0.1;
    h = 0.035;
    text = "";
    size = 0.03;
    colorText[] = { 1, 1, 1, 1 };
    colorBackground[] = { 0, 0, 0, 0 };
    font = "PuristaMedium";
};

class RscPicture {
    type = 0;
    idc = -1;
    style = 48;
    colorBackground[] = { 0, 0, 0, 0 };
    colorText[] = { 1, 1, 1, 1 };
    font = "TahomaB";
    sizeEx = 0;
    lineSpacing = 0;
    text = "";
    fixedWidth = 0;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.2;
};