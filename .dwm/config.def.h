#include "layouts.h"
#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx = 1; /* border pixel of windows */
static const int startwithgaps = 1;     /* 1 means gaps are used by default */
static const unsigned int gappx = 5; /* default gap between windows in pixels */
static const unsigned int snap = 32; /* snap pixel */
static const unsigned int systraypinning = 0; /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static const unsigned int systrayonleft = 0; /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 1; /* systray spacing */
static const int systraypinningfailfirst = 1; /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray = 1; /* 0 means no systray */
static const int showbar = 1;     /* 0 means no bar */
static const int topbar = 1;      /* 0 means bottom bar */
static const char *fonts[] = {"JetBrainsMono Nerd Font:size=9"};
static const char dmenufont[] = "JetBrainsMono Nerd Font:size=9";
static const char *upvol[] = {"/usr/bin/pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%", NULL};
static const char *downvol[] = {"/usr/bin/pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%", NULL};
static const char *mutevol[] = {"/usr/bin/pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle", NULL};
static const char *brupcmd[] = {"brightnessctl", "s", "3%+", NULL};
static const char *powermenu[] = {"/home/csh4dow/.config/dmenu/power-menu.sh", NULL};
static const char *brdowncmd[] = {"brightnessctl", "s", "3%-", NULL};
static const char *plause[] = {"playerctl", "play-pause", NULL};
static const char *next[] = {"playerctl", "next", NULL};
static const char *prev[] = {"playerctl", "previous", NULL};
static const char *lock[] = {"slock", NULL};
static const char *closen[] = {"dunstctl", "close", NULL};
static const char *closean[] = {"dunstctl", "close-all", NULL};
static const char *nhist[] = {"dunstctl", "history-pop", NULL};
static const char col_gray1[] = "#1e1e1e";
static const char col_gray2[] = "#444444";
static const char col_gray3[] = "#bbbbbb";
static const char col_gray4[] = "#d4d4d4";
static const char col_cyan[] = "#005577";
static const char *colors[][3] = {
    /*               fg         bg         border   */
    [SchemeNorm] = {col_gray3, col_gray1, col_gray2},
    [SchemeSel] = {col_gray4, col_cyan, col_cyan},
};


typedef struct {
	const char *name;
	const void *cmd;
} Sp;
const char *spcmd1[] = {"st", "-n", "spterm", "-g", "120x34", NULL };
const char *spcmd2[] = {"st", "-n", "spfm", "-g", "144x41", "-e", "ranger", NULL };
const char *spcmd3[] = {"keepassxc", NULL };
static Sp scratchpads[] = {
	/* name          cmd  */
	{"spterm",      spcmd1},
	{"spranger",    spcmd2},
	{"keepassxc",   spcmd3},
};

/* tagging */
static const char *tags[] = {"1", "2", "3", "4", "5", "6", "7", "8", "9"};

static const Rule rules[] = {
    /* xprop(1):
     *	WM_CLASS(STRING) = instance, class
     *	WM_NAME(STRING) = title
     */
  /* class        instance    title       tags mask     isfloating   monitor */
  { "Brave",      NULL,        NULL,          2,             0,        -1 },
  { "discord",    NULL,        NULL,          4,             0,        -1 },
  { "Element",    NULL,        NULL,          4,             0,        -1 },
  { "galculator", NULL,        NULL,          0,             1,        -1 },
  { NULL,		      "spterm",		 NULL,		    SPTAG(0),		     1,			   -1 },
  { NULL,		      "spfm",		   NULL,		    SPTAG(1),		     1,			   -1 },
  { "Gimp",       NULL,        NULL,           0,            1,        -1 },
  { "Firefox",    NULL,        NULL,         1 << 8,         0,        -1 },
  { "St",         NULL,        NULL,           0,            0,        -1 },
  { NULL,         NULL,      "Event Tester",   0,            0,        -1 }, /* xev */
};

/* layout(s) */
static const float mfact = 0.50; /* factor of master area size [0.05..0.95] */
static const int nmaster = 1;    /* number of clients in master area */
static const int resizehints = 1; /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
    /* symbol     arrange function */
    {"[]=",           tile}, /* first entry is default */
    {"><>",           NULL}, /* no layout function means floating behavior */
    {"[M]",           monocle},
    {"HHH",           grid},
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY, TAG)                                                  \
  {MODKEY, KEY, view, {.ui = 1 << TAG}},                                   \
  {MODKEY | ControlMask, KEY, toggleview, {.ui = 1 << TAG}},               \
  {MODKEY | ShiftMask, KEY, tag, {.ui = 1 << TAG}},                        \
  {MODKEY | ControlMask | ShiftMask, KEY, toggletag, {.ui = 1 << TAG}},

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd)                                                         \
  {                                                                        \
    .v = (const char *[]) { "/bin/sh", "-c", cmd, NULL }                   \
  }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = {"dmenu_run", "-m",      dmenumon, "-fn",    dmenufont, "-nb",     col_gray1, "-nf",       col_gray3, "-sb",    col_cyan, "-sf",     col_gray4, NULL};
static const char *termcmd[] = {"alacritty", NULL};
static const char *browser[] = {"brave-browser-beta", NULL};
static const char *discord[] = {"discord", NULL};
static const char *element[] = {"element-desktop", NULL};
static const char *browseri[] = {"brave-browser-beta", "--incognito", NULL};
static const char *explorer[] = {"pcmanfm", NULL};
static const char *music[] = {"audacious", NULL};
static const char *prtscr[] = {"scrot", "/home/csh4dow/Pictures/ss/ss.png", NULL};
static const char *prtscra[] = {"scrot", "-s", "/home/csh4dow/Pictures/ss/ss.png", NULL};
// static const char *prtscr[] = {"gnome-screenshot", NULL};
// static const char *prtscra[] = {"gnome-screenshot", "--area", NULL};

#include "selfrestart.c"
#include "shiftview.c"



static Key keys[] = {
 /* modifier                        key              function                       argument */
    {MODKEY,                        XK_p,             spawn,                      {.v = dmenucmd}},
    {MODKEY,                        XK_a,             spawn,                      {.v = music}},
    {MODKEY,                        XK_w,             spawn,                      {.v = browser}},
    {MODKEY|ShiftMask,              XK_d,             spawn,                      {.v = discord}},
    {MODKEY|ShiftMask,              XK_e,             spawn,                      {.v = element}},
    {MODKEY|ShiftMask,              XK_w,             spawn,                      {.v = browseri}},
    {MODKEY|ShiftMask,              XK_l,             spawn,                      {.v = lock}},
    {MODKEY,                        XK_e,             spawn,                      {.v = explorer}},
    {MODKEY,                        XK_Return,        spawn,                      {.v = termcmd}},
    {ControlMask,                   XK_space,         spawn,                      {.v = closen}},
    {ControlMask|ShiftMask,         XK_space,         spawn,                      {.v = closean}},
    {ControlMask|ShiftMask,         XK_grave,         spawn,                      {.v = nhist}},
    {MODKEY,                        XK_b,             togglebar,                  {0}},
    {MODKEY,                        XK_j,             focusstack,                 {.i = +1}},
    {MODKEY,                        XK_k,             focusstack,                 {.i = -1}},
    {MODKEY,                        XK_i,             incnmaster,                 {.i = +1}},
    {MODKEY,                        XK_d,             incnmaster,                 {.i = -1}},
    {MODKEY,                        XK_h,             setmfact,                   {.f = -0.05}},
    {MODKEY,                        XK_l,             setmfact,                   {.f = +0.05}},
    {MODKEY|ShiftMask,              XK_Return,        zoom,                       {0}},
    {MODKEY,                        XK_Tab,           view,                       {0}},
    {MODKEY|ShiftMask,              XK_q,             killclient,                 {0}},
    {MODKEY,                        XK_t,             setlayout,                  {.v = &layouts[0]}},
    {MODKEY,                        XK_s,             setlayout,                  {.v = &layouts[1]}},
    {MODKEY,                        XK_m,             setlayout,                  {.v = &layouts[2]}},
    {MODKEY,            			      XK_backslash,  	  togglescratch,              {.ui = 0 }},
    {MODKEY|ShiftMask,            	XK_backslash,	    togglescratch,              {.ui = 1 }},
    {MODKEY,            			      XK_x,	            togglescratch,              {.ui = 2 }},
    {MODKEY,                        XK_g,             setlayout,                  {.v = &layouts[3]}},
    {MODKEY|ControlMask,            XK_comma,         cyclelayout,                {.i = -1}},
    {MODKEY|ControlMask,            XK_period,        cyclelayout,                {.i = +1}},
    {MODKEY,                        XK_space,         setlayout,                  {0}},
    {MODKEY|ShiftMask,              XK_f,             togglefullscr,              {0}},
    {MODKEY|ShiftMask,              XK_space,         togglefloating,             {0}},
    {MODKEY|ShiftMask,              XK_t,             togglealwaysontop,          {0}},
    {MODKEY,                        XK_0,             view,                       {.ui = ~0}},
    {MODKEY|ShiftMask,              XK_0,             tag,                        {.ui = ~0}},
    {MODKEY,                        XK_comma,         focusmon,                   {.i = -1}},
    {MODKEY,                        XK_period,        focusmon,                   {.i = +1}},
    {MODKEY|ShiftMask,              XK_comma,         tagmon,                     {.i = -1}},
    {MODKEY|ShiftMask,              XK_period,        tagmon,                     {.i = +1}},
    {MODKEY,                        XK_minus,         setgaps,                    {.i = -5}},
    {MODKEY,                        XK_equal,         setgaps,                    {.i = +5}},
    {MODKEY|ShiftMask,              XK_minus,         setgaps,                    {.i = GAP_RESET}},
    {MODKEY|ShiftMask,              XK_equal,         setgaps,                    {.i = GAP_TOGGLE}},
    {MODKEY|ShiftMask,              XK_i,             shiftview,                  {.i = -1}},
    {MODKEY|ShiftMask,              XK_o,             shiftview,                  {.i = +1}},
    {0,                             XK_Print,         spawn,                      {.v = prtscr}},
    {MODKEY,                        XK_Print,         spawn,                      {.v = prtscra}},
    TAGKEYS(                        XK_1,                                         0)
    TAGKEYS(                        XK_2,                                         1)
    TAGKEYS(                        XK_3,                                         2)
    TAGKEYS(                        XK_4,                                         3)
    TAGKEYS(                        XK_5,                                         4)
    TAGKEYS(                        XK_6,                                         5)
    TAGKEYS(                        XK_7,                                         6)
    TAGKEYS(                        XK_8,                                         7)
    TAGKEYS(                        XK_9,                                         8)
    {MODKEY|ShiftMask,              XK_r,             self_restart,               {0}},
    {MODKEY|ShiftMask,              XK_c,             quit,                       {0}},
    {MODKEY|ShiftMask,              XK_p,             spawn,                      {.v = powermenu}},
    {0,                    XF86XK_AudioLowerVolume,   spawn,                      {.v = downvol}},
    {0,                    XF86XK_AudioMute,          spawn,                      {.v = mutevol}},
    {0,                    XF86XK_AudioRaiseVolume,   spawn,                      {.v = upvol}},
    {0,                    XF86XK_MonBrightnessUp,    spawn,                      {.v = brupcmd}},
    {0,                    XF86XK_MonBrightnessDown,  spawn,                      {.v = brdowncmd}},
    {0,                    XF86XK_AudioPlay,          spawn,                      {.v = plause}},
    {0,                    XF86XK_AudioNext,          spawn,                      {.v = next}},
    {0,                    XF86XK_AudioPrev,          spawn,                      {.v = prev}},
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle,
 * ClkClientWin, or ClkRootWin */
static Button buttons[] = {
    /* click                event mask      button          function      argument */
    {ClkLtSymbol,             0,            Button1,        setlayout,      {0}},
    {ClkWinTitle,             0,            Button2,        zoom,           {0}},
    {ClkClientWin,            Mod1Mask,     Button1,        movemouse,      {0}},
    {ClkClientWin,            Mod1Mask,     Button2,        togglefloating, {0}},
    {ClkClientWin,            Mod1Mask,     Button3,        resizemouse,    {0}},
	  {ClkClientWin,            MODKEY,       Button1,        resizemouse,    {0}},
    {ClkTagBar,               0,            Button1,        view,           {0}},
    {ClkTagBar,               0,            Button3,        toggleview,     {0}},
    {ClkTagBar,               MODKEY,       Button1,        tag,            {0}},
    {ClkTagBar,               MODKEY,       Button3,        toggletag,      {0}},
    {ClkLtSymbol,             0,            Button3,        setlayout,      {.v = &layouts[2]}},
    {ClkStatusText,           0,            Button2,        spawn,          {.v = termcmd}},
};
