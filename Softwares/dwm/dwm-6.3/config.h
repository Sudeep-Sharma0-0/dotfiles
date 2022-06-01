/* See LICENSE file for copyright and license details. */

#include <X11/XF86keysym.h>
#define ICONSIZE 16   /* icon size */
#define ICONSPACING 5 /* space between icon and title */

/* appearance */
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int gappx     = 3;        /* gaps between windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft = 0;   	/* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;        /* 0 means no systray */
static const int topbar             = 1;        /* 0 means bottom bar */
static const double activeopacity   = 0.960f;     /* Window opacity when it's focused (0 <= opacity <= 1) */
static const double inactiveopacity = 0.860f;   /* Window opacity when it's inactive (0 <= opacity <= 1) */
static       Bool bUseOpacity       = True;     /* Starts with opacity on any unfocused windows */
static const char *fonts[]          = { "Liberation Mono:size=9", "Iosevka Nerd Font:size=11" };
static const char dmenufont[]       = "monospace:size=10";
static const char col_gray1[]       = "#494D7E";
static const char col_gray2[]       = "#8FBCBB";
static const char col_gray3[]       = "#3DE3F2";/*"#F2EBA9";*/
static const char col_gray4[]       = "#F2F200";
static const char col_cyan[]        = "#272744";
static const char col_red1[]        = "#BC5E5E";
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_red1 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_gray2  },
};

static const char *const autostart[] = {
	"nitrogen", "--restore", NULL,
	"xsetroot", "-cursor_name", "left_ptr", NULL,
	"dunst", NULL,
	"picom", NULL,
	"xrdb", "-merge", "~/.Xresources", NULL,
	"sh", "-c", "emacs --daemon > /dev/null 2>&1", NULL,
	"flameshot", NULL,
	NULL /* terminate */
};

/* tagging */
/* static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }; */
static const char *tags[] = { "  ", "  ", "  ", "  ", "  ", " 漣 ", "  ", "  ", "  " };

static const char minecraft[] = "pl.skmedix.bootstrap.Bootstrap";
static const char stardew[] = "Stardew Valley";

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     switchtotag     isfloating   monitor */
	{ "Chromium",  NULL,       NULL,       1 << 0,          1,            0,           -1 },
	{ "Code",      NULL,       NULL,       1 << 1,          1,            0,           -1 },
	{ "Emacs",     NULL,       NULL,       1 << 1,          1,            0,           -1 },
	{ "Alacritty", NULL,       NULL,       1 << 2,          1,            0,           -1 },
	{ "st",        NULL,       NULL,       1 << 2,          1,            0,           -1 },
	{ "UnityHub",  NULL,       NULL,       1 << 3,          1,            1,           -1 },
	{ "Discord",   NULL,       NULL,       1 << 3,          1,            0,           -1 },
	{ "Thunar",    NULL,       NULL,       1 << 4,          1,            0,           -1 },
	{ minecraft,   NULL,       NULL,       1 << 6,          1,            1,           -1 },
	{ stardew,     NULL,       NULL,       1 << 6,          1,            0,           -1 },
	{ "krita",     NULL,       NULL,       1 << 8,          1,            1,           -1 },
	{ "vlc",       NULL,       NULL,       1 << 8,          1,            0,           -1 },
	{ "obs",       NULL,       NULL,       1 << 8,          1,            1,           -1 },
	{ "mpv",       NULL,       NULL,       1 << 8,          1,            0,           -1 },
	{ "mplayer",   NULL,       NULL,       1 << 8,          1,            0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "溺",      tile },    /* first entry is default */
	{ "",      NULL },    /* no layout function means floating behavior */
	{ "",      monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-b", "-p", "Launch: ", NULL };
static const char *termcmd[]  = { "st", NULL };
static const char *screenshot[] = {"flameshot", "gui", NULL};
static const char *volumeup[] = {"volumenoti.sh", "up", NULL};
static const char *volumedown[] = {"volumenoti.sh", "down", NULL};
static const char *audionext[] = {"playerctl", "next", NULL};
static const char *audioprev[] = {"playerctl", "previous", NULL};
static const char *playpause[] = {"playerctl", "play-pause", NULL};

static Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_r,      spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
    { MODKEY,                       XK_o,      toggleopacity,  {0} },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,                       XK_q,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
    { MODKEY|ShiftMask,             XK_f,      togglefullscr,  {0} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	{ MODKEY,                       XK_minus,  setgaps,        {.i = -1 } },
	{ MODKEY,                       XK_equal,  setgaps,        {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_equal,  setgaps,        {.i = 0  } },
	{ MODKEY,                       XK_Print,  spawn,          {.v = screenshot}},
	{ 0,                            0x1008ff13,  spawn,          {.v = volumeup}},
	{ 0,                            0x1008ff11,  spawn,          {.v = volumedown}},
	{ 0,                            0x1008ff17,  spawn,          {.v = audionext}},
	{ 0,                            0x1008ff16,  spawn,          {.v = audioprev}},
	{ 0,                            0x1008ff14,  spawn,          {.v = playpause}},
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_r,      quit,           {1} },
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
