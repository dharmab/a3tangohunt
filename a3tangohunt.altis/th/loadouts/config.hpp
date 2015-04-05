/*
Defines the loadout selection dialog.

This is literally the worst code I have ever worked on.
MANDATORY READING: https://community.bistudio.com/wiki/Dialog_Control
WARNING: If you screw up a single line of syntax, or forget to define a single required class member,
the game WILL crash to desktop.
*/

// A modicum of sanity
#define true 1
#define false 0

// Boilerplate constants
#define CT_STATIC 0
#define CT_BUTTON 1
#define CT_EDIT 2
#define CT_SLIDER 3
#define CT_COMBO 4
#define CT_LISTBOX 5
#define CT_TOOLBOX 6
#define CT_CHECKBOXES 7
#define CT_PROGRESS 8
#define CT_HTML 9
#define CT_STATIC_SKEW 10
#define CT_ACTIVETEXT 11
#define CT_TREE 12
#define CT_STRUCTURED_TEXT 13
#define CT_CONTEXT_MENU 14
#define CT_CONTROLS_GROUP 15
#define CT_SHORTCUTBUTTON 16
#define CT_XKEYDESC 40
#define CT_XBUTTON 41
#define CT_XLISTBOX 42
#define CT_XSLIDER 43
#define CT_XCOMBO 44
#define CT_ANIMATED_TEXTURE 45
#define CT_OBJECT 80
#define CT_OBJECT_ZOOM 81
#define CT_OBJECT_CONTAINER 82
#define CT_OBJECT_CONT_ANIM 83
#define CT_LINEBREAK 98
#define CT_ANIMATED_USER 99
#define CT_MAP 100
#define CT_MAP_MAIN 101
#define CT_LISTNBOX 102
#define CT_ITEMSLOT 103
#define CT_CHECKBOX 77

#define ST_POS 0x0F
#define ST_HPOS 0x03
#define ST_VPOS 0x0C
#define ST_LEFT 0x00
#define ST_RIGHT 0x01
#define ST_CENTER 0x02
#define ST_DOWN 0x04
#define ST_UP 0x08
#define ST_VCENTER

#define ST_TYPE 0xF0
#define ST_SINGLE 0
#define ST_MULTI 16
#define ST_TITLE_BAR 32
#define ST_PICTURE 48
#define ST_FRAME 64
#define ST_BACKGROUND 80
#define ST_GROUP_BOX 96
#define ST_GROUP_BOX2 112
#define ST_HUD_BACKGROUND 128
#define ST_TILE_PICTURE  144
#define ST_WITH_RECT 160
#define ST_LINE
#define ST_SHADOW 0x100
#define ST_NO_RECT 0x200
#define ST_KEEP_ASPECT_RATIO 0x800
#define ST_TITLE ST_TITLE_BAR + ST_CENTER

#define SL_DIR 0x400
#define SL_VERT 0
#define SL_HORZ
#define SL_TEXTURES

#define ST_VERTICAL 0x01
#define ST_HORIZONTAL

#define LB_TEXTURES 0x10
#define LB_MULTI

#define TR_SHOWROOT 1
#define TR_AUTOCOLLAPSE

#define MB_BUTTON_OK 1
#define MB_BUTTON_CANCEL 2
#define MB_BUTTON_USER 4

#define FONT "PuristaMedium"
#define FONT_SIZE 0.1;

#define BACKGROUND_COLOR {0.059,0.059,0.059,1}
#define PRIMARYCOLOR {0.918,0.655,0.141,1}

#define COLOR_BLACK {0.0, 0.0, 0.0, 1}
#define COLOR_WHITE {1.0, 1.0, 1.0, 1}

// Abstract superclass to avoid repeating ourselves
class AbstractControl
{
	access = 0;

	h = 0.0;
	w = 0.0;
	x = 0.0;
	y = 0.0;

	font = "PuristaMedium";
	sizeEx = 0.05;
};

// ListBox used to list the available loadouts
class ListBox : AbstractControl
{
	access = 0;

	style = 528;
	type = CT_LISTBOX;

	w = 1.0;
	h = 1.0;

	rowHeight = 0.05;
	rowWidth = 1.0;

	colorText[] = COLOR_WHITE;
	colorScrollbar[] = COLOR_WHITE;
	colorSelect[] = COLOR_BLACK;
	colorSelect2[] = COLOR_BLACK;
	colorSelectBackground[] = COLOR_WHITE;
	colorSelectBackground2[] = COLOR_WHITE;
	colorBackground[] = COLOR_BLACK;

	soundSelect[] = {"", 0.1, 1};

	arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
	arrowFull = "#(argb,8,8,3)color(1,1,1,1)";

	class ListScrollBar {
		color[] = {1, 1, 1, 0.6};
		colorActive[] = {1, 1, 1, 1};
		colorDisabled[] = {1, 1, 1, 0.3};
		shadow = 0;
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	};

	shadow = 0;
	colorShadow[] = COLOR_BLACK;
	color[] = COLOR_WHITE;
	colorDisabled[] = COLOR_BLACK;
	period = 1.2;
	maxHistoryDelay = 1;
	autoScrollSpeed = -1;
	autoScrollDelay = 5;
	autoScrollRewind = 0;
};

// Button used for the confirm button
class Button : AbstractControl
{
	access = 0;

	type = CT_BUTTON;
	style = ST_CENTER;

	h = 0.05;
	w = 0.10;

	text = "";

	borderSize = 0;
	colorBorder[] = COLOR_WHITE;
	colorBackgroundActive[] = COLOR_WHITE;
	colorBackgroundDisabled[] = COLOR_BLACK;
	colorDisabled[] = COLOR_BLACK;
	colorFocused[] = COLOR_BLACK;
	colorShadow[] = COLOR_WHITE;
	colorText[] = COLOR_WHITE;
	color[] = COLOR_BLACK;
	colorBackground[] = COLOR_BLACK;

	offsetPressedX = 0;
	offsetPressedY = 0;
	offsetX = 0;
	offsetY = 0;

	shadow = 0;

	soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1};
	soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1};
	blinkingPeriod = 0;
	tooltipColorShade[] = COLOR_BLACK;
	tooltipColorText[] = COLOR_WHITE;
	tooltipColorBox[] = COLOR_BLACK;

};

// The actual loadout dialog
class LoadoutSelectionDialog
{
	// Magic number used to reference the dialog in scripts
	idd = 10001;
	movingEnable = true;
	enableSimulation = true;
	class controlsBackground
	{
		class LoadoutSelectionBackground
		{
			x = 0.25;
			y = 0.25;
			w = 0.5;
			h = 0.5;
		};
	};
	class objects
	{

	};
	class controls
	{
		class LoadoutListBox : ListBox
		{
			// Magic number used to reference this listbox in scripts
			idc = 10002;
			x = 0.33;
			y = 0.15;
			w = 0.33;
			h = 0.50;

			rowWidth = 0.33;
		};
		class OkButton : Button
		{
			// Magic number that closes the dialog (???) 
			idc = 2;
			text = "Confirm Loadout";
			x = 0.33;
			y = 0.65;
			w = 0.33;
		};
	};
};