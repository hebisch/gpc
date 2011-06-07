/*Support routines for the CRT unit

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 3, or (at your
  option) any later version.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.

  As a special exception, if you link this file with files compiled
  with a GNU compiler to produce an executable, this does not cause
  the resulting executable to be covered by the GNU General Public
  License. This exception does not however invalidate any other
  reasons why the executable file might be covered by the GNU
  General Public License. */

/* @@ Request old behaviour of signal handlers, in particular
   non-restarting system calls */
#ifdef linux
#undef _XOPEN_SOURCE
#define _XOPEN_SOURCE 1
#endif

#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/time.h>
#include <signal.h>
#include "crtc.h"

#define GLOBAL(decl) decl; decl

extern int crt_InputFD, crt_OutputFD;

#ifdef USE_PDCURSES

#ifdef XCURSES

#include <xcurses.h>
#include <xpanel.h>
char *XCursesProgramName;

/* Try to shut down cleanly when X11 is shut down */
#include <setjmp.h>
static jmp_buf crt_ShutDownJump;
static int crt_ShutDownJumpActive = FALSE;

#else

#include <curses.h>
#include <panel.h>

#endif

#include <stdio.h>
#ifndef fileno
extern int fileno (FILE *f);
#endif

#define REVERSE_WORKS FALSE
#define INVIS_WORKS TRUE
#define HAVE_RAW_OUTPUT

/* This is undocumented, but there doesn't seem to be another way! */
#define SETCURSOR(x,y) wmove (curscr, y, x)

GLOBAL (int crt_Get_Input_FD (void))
{
  return PDC_get_input_fd ();
}

#ifdef XCURSES

GLOBAL (int crt_Get_Output_FD (void))
{
  return -1;
}

/* We don't have to clear the terminal since XCurses programs run in
   their own windows, anyway. */
static void crt_ClearTerminal ()
{
}

#else

GLOBAL (int crt_Get_Output_FD (void))
{
  return crt_OutputFD >= 0 ? crt_OutputFD : fileno (stdout);
}

extern int PDC_clr_scrn (WINDOW *win);

static void crt_ClearTerminal ()
{
  PDC_clr_scrn (stdscr);
}
#endif
#endif

#ifdef USE_NCURSES
#include <ncurses.h>
#include <stdio.h>  /* Needs to be included after <ncurses.h>, e.g. on Linux/Alpha, to avoid a warning */
#ifndef fileno
extern int fileno (FILE *f);
#endif

#if NCURSES_VERSION_MAJOR < 5
#error The CRT unit requires ncurses version 5.0 or newer.
#endif
#include <panel.h>
#include <term.h>
#define REVERSE_WORKS TRUE
#define INVIS_WORKS FALSE
#undef  HAVE_RAW_OUTPUT

/* From dialog-0.9 */
#define isprivate(s) ((s) != 0 && strstr (s, "\033[?") != 0)

static char *crt_Save_enter_ca_mode = NULL, *crt_Save_exit_ca_mode = NULL;

/* This is undocumented, but there doesn't seem to be another way! */
#define SETCURSOR(x,y) wmove (newscr, y, x)

GLOBAL (int crt_Get_Input_FD (void))
{
  return crt_InputFD >= 0 ? crt_InputFD : fileno (stdin);
}

GLOBAL (int crt_Get_Output_FD (void))
{
  return crt_OutputFD >= 0 ? crt_OutputFD : fileno (stdout);
}

static int putch (int c)
{
  char ch = c;
  return write (crt_Get_Output_FD (), &ch, sizeof (ch)) >= 0 ? c : EOF;
}

static void crt_ClearTerminal ()
{
  tputs (clear_screen, lines > 0 ? lines : 1, putch);
  fflush (stdout);
}

static WINDOW *resize_window (WINDOW *w, int new_lines, int new_columns)
{
  wresize (w, new_lines, new_columns);
  return w;
}
#endif

#ifndef A_ALTCHARSET
#define A_ALTCHARSET 0
#endif

#define UNUSED __attribute__ ((__unused__))

typedef unsigned char Boolean;
typedef unsigned int  TKey;
typedef unsigned char Char;
typedef unsigned char TTextAttr;
typedef enum { CursorIgnored, CursorHidden, CursorNormal, CursorFat, CursorBlock } TCursorShape;
typedef enum { UpdateNever, UpdateWaitInput, UpdateInput, UpdateRegularly, UpdateAlways } TCRTUpdate;
typedef struct { int x, y; } TPoint;

typedef struct
{
  Char Ch;
  TTextAttr Attr;
  Boolean PCCharSet;
} TCharAttr;

typedef struct
{
  int CursesKey;
  Char CRTKey;
} TKeyTable;

typedef struct TPanelData
{
  struct TPanelData *Next;
  WINDOW       *w;
  PANEL        *panel;
  Boolean      BoundToBackground, Hidden, ScrollState, PCCharSet, UseControlChars;
  TCursorShape CursorShape;
  int          WindXMin, WindXMax, WindYMin, WindYMax;
  unsigned int LastWindMin, LastWindMax;
  TTextAttr    TextAttr;
} TPanelData;
typedef TPanelData *TPanel;

extern int crt_VirtualShiftState;
extern char *crt_Terminal;
extern unsigned int crt_LastMode, crt_WindMin, crt_WindMax;
extern Boolean crt_CheckBreak, crt_CheckEOF, crt_VisualBell, crt_IsMonochrome, crt_TerminalNoCRT, crt_ClearFlag;
extern int crt_CursorShapeHidden, crt_CursorShapeNormal, crt_CursorShapeFull;
extern TTextAttr crt_TextAttr, crt_NormAttr;
extern void (*crt_AutoInitProc) (void);
extern TPoint crt_ScreenSize, crt_Cursor;

/* modified by signal handlers */
extern volatile Boolean crt_Signaled;
static volatile Boolean crt_ScreenSizeChanged = FALSE, crt_ShutDown = FALSE;
static volatile TKey crt_UngetKeyBuf = 0;

extern char *crt_GetProgramName (void);
extern char **crt_GetCEnvironment (void);
extern void crt_DoTextModeCommand (int, int);
extern void crt_RegisterRestoreTerminal (void);
extern void crt_SignalHandler (TKey sig);
extern void crt_Fatal (int) __attribute__ ((noreturn));
extern void _p_SetReturnAddress (void *);
extern void _p_RestoreReturnAddress (void);
extern Boolean _p_IsPrintable (Char);

#define SAVE_RETURN_ADDRESS _p_SetReturnAddress (__builtin_return_address (0))
#define RESTORE_RETURN_ADDRESS _p_RestoreReturnAddress ()
#define DO_RETURN_ADDRESS(stmt) \
do \
  { \
    SAVE_RETURN_ADDRESS; \
    stmt; \
    RESTORE_RETURN_ADDRESS; \
  } \
while (0)

static void crt_Refresh (void);
void crt_Check_WinChanged (void);
int crt_DefaultSaveRestoreScreen (Boolean Restore);

#define DO_CRT_CHECK_WINCHANGED DO_RETURN_ADDRESS (crt_Check_WinChanged ())

/*
There are a few features that cannot be implemented in a portable
way, but rather for different systems individually. There are
defaults for systems where they are not specially supported, see the
comment in crt.pas. The following table lists these items, how to
check them in CRTDemo, and how to implement them on a new system.
Implementations for new systems should go into separate files,
included with appropriate ifdefs below this comment. Prototypes of
the functions to be implemented can be found there.

- Playing sounds with Sound and NoSound. In CRTDemo, this can be
  checked with the `Sound check' in the `Various checks' window.

  To support them on a system, define HAVE_CRT_SOUND and implement
  the functions crt_Sound() (start playing a sound of the given
  frequency, until the next crt_Sound() or crt_NoSound() call), and
  crt_NoSound() (stop playing any sound).

- Getting the keyboard shift state. In CRTDemo, this can be checked
  in the `Modifier Keys' window.

  By default, this is supported on PDCurses platforms. To support
  this on another system (or to override the PDCurses version),
  define HAVE_CRT_GETSHIFTSTATE and implement the function
  crt_GetShiftState() (return the keyboard shift state as a
  combination of the shFoo constants, ORed with the value of the
  variable crt_VirtualShiftState).

- Changing the screen size with TextMode. In CRTDemo, this can be
  checked by changing `Screen columns' and/or `Screen lines' in the
  `Status' window.

  By default, this is supported on PDCurses platforms except X11
  (and changing the number of columns doesn't work everywhere). For
  ncurses platforms, the code tries to change the size via an
  external executable. To support this on another system (or to
  override the PDCurses version), define HAVE_CRT_GETSHIFTSTATE and
  implement the function crt_ChangeScreenSize() (change the screen
  size to the given size).

- Saving and restoring the original screen contents (e.g., after and
  before starting a child program.

  By default, this is supported if the terminal supports it via
  smcup/rmcup (as, e.g., xterms do), and it's not necessary on
  XCurses where the program runs in its own window, anyway. To
  support this on another system, define
  HAVE_CRT_SAVE_RESTORE_SCREEN and implement the function
  crt_SaveRestoreScreen() (save or restore the screen contents).

- Catching INT (Ctrl-C) and/or TERM, HUP and under XCurses also PIPE
  signals to let them be treated by CRT, dependent on CheckBreak. In
  CRTDemo, this can be checked by verifying that the program reacts
  to interrupt (Ctrl-C) keys (and if applicable, suspend (Ctrl-Z)
  keys as well as to being killed with INT, TERM, HUP signals, or
  for XCurses, shutting down X11) appropriately, depending on the
  setting of `Break checking' in the `Status' window. Also, catching
  WINCH signals. In CRTDemo, this can by checked by resizing the
  terminal or window by external means and verifying that the
  `Status' window recognizes the new screen size.

  By default, handlers are implemented for any of these signals
  which are actually defined on the system. These handlers have been
  found working on all systems tested so far, so usually you won't
  have to worry about them. If you want to implement different
  handlers, define HAVE_CRT_SIGNAL_HANDLERS, and implement the
  function crt_InitSignals() (install the signal handlers at the
  start of the program). The signal handlers, in turn, should call
  crt_SignalHandler() whenever an INT, TERM, HUP or similar signal
  or SIGPIPE under XCurses is received, giving it as an argument a
  pseudo key code for the signal, and make sure that the program is
  not aborted by the signal. Reading a character from the curses
  window should be interrupted by the signal (which ought to happen
  by default), in order for the program to receive the pseudo key
  immediately. The signal handler for WINCH should set
  crt_ScreenSizeChanged and crt_Signaled, and call any previously
  installed signal handler (e.g. ncurses' one).
*/
static void crt_ChangeScreenSize (int Columns, int Lines);
static int crt_SaveRestoreScreen (Boolean Restore);
static void crt_InitSignals (void);

#if defined (__linux__) && defined (__i386__) && !defined (XCURSES)
#include "crtlinux386.h"
#elif defined (__GO32__)
#include "crtdjgpp.h"
#endif

#define MAXLENGTH 4096

static TCRTUpdate   crt_UpdateLevel = UpdateWaitInput;
static TCursorShape crt_LastShape = -1;
static Char    crt_FKeyBuf = 0, crt_LineBuf[MAXLENGTH], *crt_LineBufPos = crt_LineBuf;
static size_t  crt_LineBufCount = 0;
static TPanel  crt_ActivePanel = NULL, crt_PanelList = NULL;
static PANEL   *crt_SimulateBlockCursorPanel = NULL;
static WINDOW  *crt_DummyPad = NULL;
static int     crt_Inited = 0, crt_KeyBuf = 0,
               crt_RefreshInhibit = 0, crt_RefreshFlag = 0,
               crt_SavePreviousScreenFlag = -2,
               crt_Colors[8] = { COLOR_BLACK, COLOR_BLUE,    COLOR_GREEN,  COLOR_CYAN,
                                 COLOR_RED,   COLOR_MAGENTA, COLOR_YELLOW, COLOR_WHITE };
static chtype  crt_Attrs[8][8], crt_MonoAttrs[8][8];
static Boolean crt_ColorFlag = FALSE,
               crt_HasColors = FALSE,
               crt_ScreenRestored = FALSE,
               crt_LinuxConsole = FALSE,
               crt_LastCheckBreak = -1,
               crt_PendingRefresh = FALSE,
               crt_PCCharSet = FALSE,
               crt_UpdateLevelChanged = FALSE,
               crt_SimulateBlockCursorActive = FALSE;

#define KEY_HUP    (KEY_MAX + 1)
#ifndef KEY_RESIZE
#define KEY_RESIZE (KEY_MAX + 2)
#endif

#define FKEY1     KEY_F (1)
#define FKEYSH1   KEY_F (13)
#define FKEYCTRL1 KEY_F (25)
#define FKEYALT1  KEY_F (37)

static TKeyTable KeyTable[] =
{
  { KEY_BACKSPACE, chBkSp },
  { '\b',          chBkSp },
  { 127,           chBkSp },
  { KEY_SUSPEND,   26     },
  { '\n',          chCR   },
  #ifdef USE_PDCURSES
  { '\r',          chCR   },
  { PADSTAR,       '*'    },
  { PADMINUS,      '-'    },
  { PADPLUS,       '+'    },
  { PADSLASH,      '/'    },
  { PADENTER,      chLF   },
  { CTL_ENTER,     chLF   },
  { CTL_PADENTER,  chLF   },
  { CTL_PADSTAR,   chLF   },
  { CTL_PADMINUS,  chCR   },
  { CTL_PADPLUS,   11     },
  { CTL_PADSLASH,  '/'    },
  { SHF_PADSLASH,  '/'    },
  { SHF_PADENTER,  chLF   },
  #else
  { '\r',          chLF   },
  #endif
  { 0,             0      }
};

static TKeyTable FKeyTable[] =
{
  { KEY_RESIZE,     ksScreenSizeChanged },
  { KEY_BTAB,       ksShTab     },
  { KEY_LEFT,       ksLeft      },
  { KEY_RIGHT,      ksRight     },
  { KEY_UP,         ksUp        },
  { KEY_DOWN,       ksDown      },
  { KEY_A3,         ksPgUp      },
  { KEY_PPAGE,      ksPgUp      },
  { KEY_C3,         ksPgDn      },
  { KEY_NPAGE,      ksPgDn      },
  { KEY_A1,         ksHome      },
  { KEY_HOME,       ksHome      },
  { KEY_C1,         ksEnd       },
  { KEY_END,        ksEnd       },
  { KEY_IC,         ksIns       },
  { KEY_DC,         ksDel       },
  { KEY_B2,         ksCenter    },
  { KEY_CANCEL,     ksCancel    },
  { KEY_COPY,       ksCopy      },
  { KEY_UNDO,       ksUndo      },
  { KEY_REDO,       ksRedo      },
  { KEY_OPEN,       ksOpen      },
  { KEY_CLOSE,      ksClose     },
  { KEY_COMMAND,    ksCommand   },
  { KEY_CREATE,     ksCreate    },
  { KEY_EXIT,       ksExit      },
  { KEY_FIND,       ksFind      },
  { KEY_HELP,       ksHelp      },
  { KEY_MARK,       ksMark      },
  { KEY_MESSAGE,    ksMessage   },
  { KEY_MOVE,       ksMove      },
  { KEY_NEXT,       ksNext      },
  { KEY_PREVIOUS,   ksPrevious  },
  { KEY_OPTIONS,    ksOptions   },
  { KEY_REFERENCE,  ksReference },
  { KEY_REFRESH,    ksRefresh   },
  { KEY_REPLACE,    ksReplace   },
  { KEY_RESTART,    ksRestart   },
  { KEY_SUSPEND,    ksSuspend   },
  { KEY_RESUME,     ksResume    },
  { KEY_SAVE,       ksSave      },
  #ifdef XCURSES
  /* XCurses returns these for *shifted* keys (which is not wrong :-).
     However, we don't have key codes for shifted keys, but we can get
     the shift state via crt_GetShiftState(). Control-key combinations
     are obtained using crt_GetShiftState(). */
  { KEY_SLEFT,      ksLeft      },
  { KEY_SRIGHT,     ksRight     },
  { KEY_SHOME,      ksHome      },
  { KEY_SEND,       ksEnd       },
  { KEY_SDC,        ksDel       },
  { KEY_SIC,        ksIns       },
  #else
  { KEY_SLEFT,      ksCtrlLeft  },
  { KEY_SRIGHT,     ksCtrlRight },
  { KEY_SHOME,      ksCtrlHome  },
  { KEY_SEND,       ksCtrlEnd   },
  { KEY_SDC,        ksCtrlDel   },
  { KEY_SIC,        ksCtrlIns   },
  #endif
  #ifdef USE_PDCURSES
  { KEY_A2,         ksUp        },
  { KEY_B1,         ksLeft      },
  { KEY_B3,         ksRight     },
  { KEY_C2,         ksDown      },
  { CTL_BKSP,       ksCtrlBkSp  },
  { CTL_TAB,        ksCtrlTab   },
  { CTL_LEFT,       ksCtrlLeft  },
  { CTL_RIGHT,      ksCtrlRight },
  { CTL_UP,         ksCtrlUp    },
  { CTL_DOWN,       ksCtrlDown  },
  { CTL_PGUP,       ksCtrlPgUp  },
  { CTL_PGDN,       ksCtrlPgDn  },
  { CTL_HOME,       ksCtrlHome  },
  { CTL_END,        ksCtrlEnd   },
  { CTL_INS,        ksCtrlIns   },
  { CTL_DEL,        ksCtrlDel   },
  { CTL_PADSTOP,    ksCtrlDel   },
  { CTL_PADCENTER,  ksCtrlCentr },
  { ALT_TAB,        ksAltTab    },
  { ALT_LEFT,       ksAltLeft   },
  { ALT_RIGHT,      ksAltRight  },
  { ALT_UP,         ksAltUp     },
  { ALT_DOWN,       ksAltDown   },
  { ALT_PGUP,       ksAltPgUp   },
  { ALT_PGDN,       ksAltPgDn   },
  { ALT_HOME,       ksAltHome   },
  { ALT_END,        ksAltEnd    },
  { ALT_INS,        ksAltIns    },
  { ALT_DEL,        ksAltDel    },
  { ALT_ENTER,      ksAltEnter  },
  { ALT_PADENTER,   ksAltEnter  },
  { ALT_PADSTAR,    ksAltPStar  },
  { ALT_PADMINUS,   ksAltPMinus },
  { ALT_PADPLUS,    ksAltPPlus  },
  { ALT_PADSLASH,   ksAltFSlash },
  { ALT_ESC,        ksAltEsc    },
  { ALT_BKSP,       ksAltBkSp   },
  { ALT_MINUS,      ksAltMinus  },
  { ALT_EQUAL,      ksAltEqual  },
  { ALT_LBRACKET,   ksAltLBrack },
  { ALT_RBRACKET,   ksAltRBrack },
  { ALT_SEMICOLON,  ksAltSemic  },
  { ALT_FQUOTE,     ksAltFQuote },
  { ALT_BQUOTE,     ksAltBQuote },
  { ALT_COMMA,      ksAltComma  },
  { ALT_STOP,       ksAltStop   },
  { ALT_FSLASH,     ksAltFSlash },
  { ALT_BSLASH,     ksAltBSlash },
  { ALT_0,          ksAlt0      },
  { ALT_1,          ksAlt1      },
  { ALT_2,          ksAlt2      },
  { ALT_3,          ksAlt3      },
  { ALT_4,          ksAlt4      },
  { ALT_5,          ksAlt5      },
  { ALT_6,          ksAlt6      },
  { ALT_7,          ksAlt7      },
  { ALT_8,          ksAlt8      },
  { ALT_9,          ksAlt9      },
  { ALT_A,          ksAltA      },
  { ALT_B,          ksAltB      },
  { ALT_C,          ksAltC      },
  { ALT_D,          ksAltD      },
  { ALT_E,          ksAltE      },
  { ALT_F,          ksAltF      },
  { ALT_G,          ksAltG      },
  { ALT_H,          ksAltH      },
  { ALT_I,          ksAltI      },
  { ALT_J,          ksAltJ      },
  { ALT_K,          ksAltK      },
  { ALT_L,          ksAltL      },
  { ALT_M,          ksAltM      },
  { ALT_N,          ksAltN      },
  { ALT_O,          ksAltO      },
  { ALT_P,          ksAltP      },
  { ALT_Q,          ksAltQ      },
  { ALT_R,          ksAltR      },
  { ALT_S,          ksAltS      },
  { ALT_T,          ksAltT      },
  { ALT_U,          ksAltU      },
  { ALT_V,          ksAltV      },
  { ALT_W,          ksAltW      },
  { ALT_X,          ksAltX      },
  { ALT_Y,          ksAltY      },
  { ALT_Z,          ksAltZ      },
  #endif
  { FKEYSH1 + 10,   ksShF11     },
  { FKEYSH1 + 11,   ksShF12     },
  { FKEYCTRL1 + 10, ksCtrlF11   },
  { FKEYCTRL1 + 11, ksCtrlF12   },
  { FKEYALT1 + 10,  ksAltF11    },
  { FKEYALT1 + 11,  ksAltF12    },
  { 0,              ksUnknown   }
};

static TKeyTable ShiftKeyTable[] =
{
  { chTab, ksShTab },
  { 0,     0       }
};

static TKeyTable ShiftFKeyTable[] =
{
  { ksIns, ksShIns },
  { ksDel, ksShDel },
  { 0,     0       }
};

static TKeyTable ShiftCtrlFKeyTable[] =
{
  { ksIns, ksShCtrlIns },
  { ksDel, ksShCtrlDel },
  { 0,     0           }
};

static TKeyTable CtrlFKeyTable[] =
{
  { ksLeft,   ksCtrlLeft  },
  { ksRight,  ksCtrlRight },
  { ksUp,     ksCtrlUp    },
  { ksDown,   ksCtrlDown  },
  { ksPgUp,   ksCtrlPgUp  },
  { ksPgDn,   ksCtrlPgDn  },
  { ksHome,   ksCtrlHome  },
  { ksEnd,    ksCtrlEnd   },
  { ksIns,    ksCtrlIns   },
  { ksDel,    ksCtrlDel   },
  { ksCenter, ksCtrlCentr },
  { ksF1,     ksCtrlF1    },
  { ksF2,     ksCtrlF2    },
  { ksF3,     ksCtrlF3    },
  { ksF4,     ksCtrlF4    },
  { ksF5,     ksCtrlF5    },
  { ksF6,     ksCtrlF6    },
  { ksF7,     ksCtrlF7    },
  { ksF8,     ksCtrlF8    },
  { ksF9,     ksCtrlF9    },
  { ksF10,    ksCtrlF10   },
  { ksF11,    ksCtrlF11   },
  { ksF12,    ksCtrlF12   },
  { 0,        0           }
};

static TKeyTable AltFKeyTable[] =
{
  { ksLeft,   ksAltLeft  },
  { ksRight,  ksAltRight },
  { ksUp,     ksAltUp    },
  { ksDown,   ksAltDown  },
  { ksPgUp,   ksAltPgUp  },
  { ksPgDn,   ksAltPgDn  },
  { ksHome,   ksAltHome  },
  { ksEnd,    ksAltEnd   },
  { ksIns,    ksAltIns   },
  { ksDel,    ksAltDel   },
  { 0,        0          }
};

static TKeyTable AltKeyTable[] =
{
  { ' ',  ksAltSpace },
  { chLF, ksAltEnter },
  { chCR, ksAltEnter },
  { 0,    0          }
};

static TKeyTable AltGrKeyTable[] =
{
  { '0',   ksAltGr0 },
  { '1',   ksAltGr1 },
  { '2',   ksAltGr2 },
  { '3',   ksAltGr3 },
  { '4',   ksAltGr4 },
  { '5',   ksAltGr5 },
  { '6',   ksAltGr6 },
  { '7',   ksAltGr7 },
  { '8',   ksAltGr8 },
  { '9',   ksAltGr9 },
  { 'A',   ksAltGrA },
  { 'B',   ksAltGrB },
  { 'C',   ksAltGrC },
  { 'D',   ksAltGrD },
  { 'E',   ksAltGrE },
  { 'F',   ksAltGrF },
  { 'G',   ksAltGrG },
  { 'H',   ksAltGrH },
  { 'I',   ksAltGrI },
  { 'J',   ksAltGrJ },
  { 'K',   ksAltGrK },
  { 'L',   ksAltGrL },
  { 'M',   ksAltGrM },
  { 'N',   ksAltGrN },
  { 'O',   ksAltGrO },
  { 'P',   ksAltGrP },
  { 'Q',   ksAltGrQ },
  { 'R',   ksAltGrR },
  { 'S',   ksAltGrS },
  { 'T',   ksAltGrT },
  { 'U',   ksAltGrU },
  { 'V',   ksAltGrV },
  { 'W',   ksAltGrW },
  { 'X',   ksAltGrX },
  { 'Y',   ksAltGrY },
  { 'Z',   ksAltGrZ },
  #ifdef USE_PDCURSES
  { ALT_0, ksAltGr0 },
  { ALT_1, ksAltGr1 },
  { ALT_2, ksAltGr2 },
  { ALT_3, ksAltGr3 },
  { ALT_4, ksAltGr4 },
  { ALT_5, ksAltGr5 },
  { ALT_6, ksAltGr6 },
  { ALT_7, ksAltGr7 },
  { ALT_8, ksAltGr8 },
  { ALT_9, ksAltGr9 },
  { ALT_A, ksAltGrA },
  { ALT_B, ksAltGrB },
  { ALT_C, ksAltGrC },
  { ALT_D, ksAltGrD },
  { ALT_E, ksAltGrE },
  { ALT_F, ksAltGrF },
  { ALT_G, ksAltGrG },
  { ALT_H, ksAltGrH },
  { ALT_I, ksAltGrI },
  { ALT_J, ksAltGrJ },
  { ALT_K, ksAltGrK },
  { ALT_L, ksAltGrL },
  { ALT_M, ksAltGrM },
  { ALT_N, ksAltGrN },
  { ALT_O, ksAltGrO },
  { ALT_P, ksAltGrP },
  { ALT_Q, ksAltGrQ },
  { ALT_R, ksAltGrR },
  { ALT_S, ksAltGrS },
  { ALT_T, ksAltGrT },
  { ALT_U, ksAltGrU },
  { ALT_V, ksAltGrV },
  { ALT_W, ksAltGrW },
  { ALT_X, ksAltGrX },
  { ALT_Y, ksAltGrY },
  { ALT_Z, ksAltGrZ },
  #endif
  { 0,     0        }
};

static TKeyTable ExtraKeyTable[] =
{
  { '0', ksExtra0 },
  { '1', ksExtra1 },
  { '2', ksExtra2 },
  { '3', ksExtra3 },
  { '4', ksExtra4 },
  { '5', ksExtra5 },
  { '6', ksExtra6 },
  { '7', ksExtra7 },
  { '8', ksExtra8 },
  { '9', ksExtra9 },
  { 'A', ksExtraA },
  { 'B', ksExtraB },
  { 'C', ksExtraC },
  { 'D', ksExtraD },
  { 'E', ksExtraE },
  { 'F', ksExtraF },
  { 'G', ksExtraG },
  { 'H', ksExtraH },
  { 'I', ksExtraI },
  { 'J', ksExtraJ },
  { 'K', ksExtraK },
  { 'L', ksExtraL },
  { 'M', ksExtraM },
  { 'N', ksExtraN },
  { 'O', ksExtraO },
  { 'P', ksExtraP },
  { 'Q', ksExtraQ },
  { 'R', ksExtraR },
  { 'S', ksExtraS },
  { 'T', ksExtraT },
  { 'U', ksExtraU },
  { 'V', ksExtraV },
  { 'W', ksExtraW },
  { 'X', ksExtraX },
  { 'Y', ksExtraY },
  { 'Z', ksExtraZ },
  { 0,   0       }
};

static TKeyTable EscKeyTable[] =
{
  { KEY_BACKSPACE, ksAltBkSp   },
  { chBkSp,        ksAltBkSp   },
  { chTab,         ksAltTab    },
  { chLF,          ksAltEnter  },
  { chCR,          ksAltEnter  },
  { chEsc,         ksAltEsc    },
  { ' ',           ksAltSpace  },
  { '-',           ksAltMinus  },
  { '=',           ksAltEqual  },
  { '[',           ksAltLBrack },
  { ']',           ksAltRBrack },
  { ';',           ksAltSemic  },
  { '\'',          ksAltFQuote },
  { '`',           ksAltBQuote },
  { ',',           ksAltComma  },
  { '.',           ksAltStop   },
  { '/',           ksAltFSlash },
  { '\\',          ksAltBSlash },
  { 'A',           ksAltA      },
  { 'B',           ksAltB      },
  { 'C',           ksAltC      },
  { 'D',           ksAltD      },
  { 'E',           ksAltE      },
  { 'F',           ksAltF      },
  { 'G',           ksAltG      },
  { 'H',           ksAltH      },
  { 'I',           ksAltI      },
  { 'J',           ksAltJ      },
  { 'K',           ksAltK      },
  { 'L',           ksAltL      },
  { 'M',           ksAltM      },
  { 'N',           ksAltN      },
  { 'O',           ksAltO      },
  { 'P',           ksAltP      },
  { 'Q',           ksAltQ      },
  { 'R',           ksAltR      },
  { 'S',           ksAltS      },
  { 'T',           ksAltT      },
  { 'U',           ksAltU      },
  { 'V',           ksAltV      },
  { 'W',           ksAltW      },
  { 'X',           ksAltX      },
  { 'Y',           ksAltY      },
  { 'Z',           ksAltZ      },
  { '0',           ksAlt0      },
  { '1',           ksAlt1      },
  { '2',           ksAlt2      },
  { '3',           ksAlt3      },
  { '4',           ksAlt4      },
  { '5',           ksAlt5      },
  { '6',           ksAlt6      },
  { '7',           ksAlt7      },
  { '8',           ksAlt8      },
  { '9',           ksAlt9      },
  { 0,             0           }
};

#if !defined (USE_PDCURSES) || defined (XCURSES)
static chtype chars_0_31[32] =
{
  ' ', 'O', 'O', '%',   0, '#', '*', 'o', 'o', 'o', 'o', '/', '+', 'd', 'A', '*',
    0,   0,   0, '!', '#', '$',   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
};

static chtype chars_128_255[128] =
{
  'C', 'u', 'e', 'a', 'a', 'a', 'a', 'c', 'e', 'e', 'e', 'i', 'i', 'i', 'A', 'A',
  'E', 'a', 'A', 'o', 'o', 'o', 'u', 'u', 'y', 'O', 'U', 'C',   0, 'Y', 'P', 'f',
  'a', 'i', 'o', 'u', 'n', 'N',   0,   0, '?',   0,   0, '/', '/', '!',   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  'a', 'B', 'T',   0, 'E', 'o', 'u', 't', 'O', 'O', 'O', 'O', 'o', 'o', 'E', 'A',
  '=',   0,   0,   0, '/', '/', '%', '=',   0, '.', '.', 'V', 'n', '2',   0, ' '
};
#endif

#ifndef HAVE_CRT_SETTEXTMODE
static void crt_ChangeScreenSize (int Columns UNUSED, int Lines UNUSED)
{
  #ifdef USE_PDCURSES
  #ifdef XCURSES
  /* Don't call resize_term() here -- leads to segfaults (PDCurses 2.4beta.22-May-99) */
  #else
  resize_term (Lines, Columns);
  resize_term (Lines, Columns);  /* @@ does not always work the first time -- DJGPP bug? */
  crt_ScreenSizeChanged = TRUE;
  #endif
  #endif
  #ifdef USE_NCURSES
  crt_DoTextModeCommand (Columns, Lines);
  if (!crt_Signaled)
    napms (1000);  /* give the kernel some time to change the size of
                      all consoles -- a SIGWINCH will interrupt this */
  #endif
}
#endif

/* Return value:
    1: available
    0: not available
   -1: unknown until ncurses is initialized
   Values of crt_SavePreviousScreenFlag are the same plus:
   -2: not requested
   -3: explicitly disabled by user */
int crt_DefaultSaveRestoreScreen (Boolean Restore UNUSED)
{
  /* The smcup/rmcup support is implicit in ncurses. */
  #ifdef USE_NCURSES
  /* Before ncurses is initialized, exit_ca_mode may be undefined
     (not NULL, but a macro dereferencing NULL) */
  if (!crt_Inited)
    return -1;
  return isprivate (Restore ? exit_ca_mode : enter_ca_mode);
  #elif defined (XCURSES)
  return 1;
  #else
  return 0;
  #endif
}

#ifndef HAVE_CRT_SAVE_RESTORE_SCREEN
static int crt_SaveRestoreScreen (Boolean Restore)
{
  return crt_DefaultSaveRestoreScreen (Restore);
}
#endif

#ifndef HAVE_CRT_GETSHIFTSTATE
GLOBAL (int crt_GetShiftState (void))
{
  int state = crt_VirtualShiftState;
  #ifdef USE_PDCURSES
  unsigned long modifiers;
  DO_CRT_CHECK_WINCHANGED;
  modifiers = PDC_get_key_modifiers ();
  if (modifiers & PDC_KEY_MODIFIER_SHIFT  ) state |= shShift;
  if (modifiers & PDC_KEY_MODIFIER_CONTROL) state |= shCtrl;
  if (modifiers & PDC_KEY_MODIFIER_ALT    ) state |= shAlt;
  #ifdef XCURSES
  if (modifiers & PDC_KEY_MODIFIER_MOD4   ) state |= shExtra;
  if (modifiers & PDC_KEY_MODIFIER_MOD3   ) state = shAltGr;
  #elif !defined (_WIN32)
  if (modifiers & PDC_KEY_MODIFIER_NUMLOCK) state |= shExtra;
  #endif
  #endif
  return state;
}
#endif

#ifndef HAVE_CRT_SIGNAL_HANDLERS
#ifdef SIGINT
static void int_handler (int sig UNUSED)
{
  /* PDCurses under DJGPP gets a SIGINT for Ctrl-C even in raw mode.
     In XCurses, stop Ctrl-C on the controlling terminal,
     cf. the comment in crt_Init(). */
  if (crt_CheckBreak)
    {
      #ifdef XCURSES
      crt_ShutDown = TRUE;
      #endif
      crt_SignalHandler (0x100 * ksInt);
    }
  signal (SIGINT, &int_handler);
}
#endif

#ifdef SIGTERM
static void term_handler (int sig UNUSED)
{
  #ifdef XCURSES
  crt_ShutDown = TRUE;
  #endif
  crt_SignalHandler (0x100 * ksTerm);
  signal (SIGTERM, &term_handler);
}
#endif

#ifdef SIGHUP
static void hup_handler (int sig UNUSED)
{
  #ifdef XCURSES
  crt_ShutDown = TRUE;
  #endif
  crt_SignalHandler (0x100 * ksHUp);
  signal (SIGHUP, &hup_handler);
}
#endif

#if defined (SIGPIPE) && defined (XCURSES)
static void pipe_handler (int sig UNUSED)
{
  crt_ShutDown = TRUE;
  crt_SignalHandler (0x100 * ksHUp);
  signal (SIGPIPE, SIG_IGN);
  if (crt_ShutDownJumpActive)
    longjmp (crt_ShutDownJump, 1);
}
#endif

#if defined (SIGTSTP) && !defined (XCURSES)
static void (*crt_OldTSTPHandler) (int);

static void tstp_handler (int sig UNUSED)
{
  signal (SIGTSTP, crt_OldTSTPHandler);
  kill (getpid (), SIGTSTP);
  signal (SIGTSTP, &tstp_handler);
  crt_ScreenSizeChanged = TRUE;  /* might have changed while we were stopped */
}
#endif

#ifdef SIGWINCH
static void (*crt_OldWINCHHandler) (int) = SIG_ERR;

static void winch_handler (int sig)
{
  crt_ScreenSizeChanged = TRUE;
  crt_Signaled = TRUE;
  if (crt_OldWINCHHandler != SIG_ERR && crt_OldWINCHHandler != SIG_IGN && crt_OldWINCHHandler != SIG_DFL)
    (*crt_OldWINCHHandler) (sig);
  signal (SIGWINCH, &winch_handler);
}
#endif

static void crt_InitSignals ()
{
  #ifdef SIGINT
  signal (SIGINT, &int_handler);
  #endif
  #ifdef SIGTERM
  signal (SIGTERM, &term_handler);
  #endif
  #ifdef SIGHUP
  signal (SIGHUP, &hup_handler);
  #endif
  #if defined (SIGPIPE) && defined (XCURSES)
  signal (SIGPIPE, &pipe_handler);
  #endif
  #if defined (SIGTSTP) && !defined (XCURSES)
  crt_OldTSTPHandler = signal (SIGTSTP, &tstp_handler);
  #endif
  #ifdef SIGWINCH
  #ifdef XCURSES
  /* SIGWINCH refers to the console from which the program was started.
     It would confuse PDCurses. */
  signal (SIGWINCH, SIG_IGN);
  #else
  crt_OldWINCHHandler = signal (SIGWINCH, &winch_handler);
  #endif
  #endif
}
#endif

#if !defined (HAVE_CRT_SOUND) && !defined (NO_CRT_DUMMY_SOUND)
GLOBAL (void crt_Sound (unsigned Hz UNUSED))
{
}

GLOBAL (void crt_NoSound (void))
{
}
#endif

#if defined (USE_NCURSES) || defined (XCURSES)

/* Time for delayed refreshes */
#define REFRESH_SECONDS 0
#define REFRESH_MICROSECONDS 100000

static void alarm_handler (int sig UNUSED)
{
  crt_Refresh ();
}

static void no_alarm_handler (int sig UNUSED)
{
}

/* This function must call crt_Refresh(), either immediately, or
   delayed (e.g. using a timer signal).
   - Calling crt_Refresh() immediately is useful if curses'
     wrefresh() does not take a long time, like PDCurses under DJGPP
     which uses direct hardware access. The CRT window will then
     always be up to date. However, if wrefresh() takes a long time,
     this will slow down the program substantially.
   - Calling crt_Refresh() delayed (e.g. Unix with ncurses): By
     using a timer, the number of calls to wrefresh() can be reduced
     so the program will not be slowed down too much. On the other
     hand, the timer guarantees that the window will not lag behind
     more than a specified amount of time. crt_Refresh() is
     re-entrant, so the timer signal handler can call it without
     worries. Also, crt_ScheduleRefresh() will not be called when
     there is a pending refresh (i.e. crt_ScheduleRefresh() was
     called, but crt_Refresh() was not called since then), so it can
     set the timer without worrying about disturbing a previously
     scheduled refresh. */
static void crt_ScheduleRefresh ()
{
  static struct itimerval timerval = { { 0, 0 }, { REFRESH_SECONDS, REFRESH_MICROSECONDS } };
  signal (SIGALRM, &alarm_handler);
  setitimer (ITIMER_REAL, &timerval, 0);
}

/* Called before a Delay is started, a (blocking) read is done, a
   child process is executed, or the update level is changed, i.e.
   when a scheduled refresh should not be done any more because it
   or its timer event might disturb another operation. If
   crt_ScheduleRefresh() has set a timer, this function must clear
   it, otherwise it might interfere with the Delay or the read, so
   e.g. Delay might get too short or the read will not read in all
   characters. crt_Refresh() will be called after this function, so
   the timer can safely be cleared without losing the refresh. */
static void crt_StopRefresh ()
{
  static struct itimerval no_timerval = { { 0, 0 }, { 0, 0 } };
  signal (SIGALRM, &no_alarm_handler);
  setitimer (ITIMER_REAL, &no_timerval, 0);
}

#else

static inline void crt_ScheduleRefresh ()
{
  crt_Refresh ();
}

static void crt_StopRefresh ()
{
}
#endif

static void crt_SetCBreak ()
{
  if (crt_CheckBreak)
    {
      noraw ();
      cbreak ();
    }
  else
    raw ();
}

static void crt_NoDelay (bool bf)
{
  crt_SetCBreak ();
  nodelay (crt_ActivePanel->w, bf);
  nodelay (stdscr, bf);
}

static void crt_CheckCheckBreak ()
{
  if (crt_CheckBreak != crt_LastCheckBreak)
    {
      crt_LastCheckBreak = crt_CheckBreak;
      crt_SetCBreak ();
    }
}

static TPanel CheckPanel (TPanel Panel)
{
  TPanel PList = crt_PanelList;
  while (PList && PList != Panel) PList = PList->Next;
  return PList;
}

GLOBAL (TPanel crt_PanelAbove (TPanel Panel))
{
  PANEL *p;
  if (Panel && !CheckPanel (Panel)) return NULL;
  p = Panel ? Panel->panel : NULL;
  do
    p = panel_above (p);
  while (p && !panel_userptr (p));
  return p ? (TPanel) panel_userptr (p) : NULL;
}

GLOBAL (TPanel crt_PanelBelow (TPanel Panel))
{
  PANEL *p;
  if (Panel && !CheckPanel (Panel)) return NULL;
  p = Panel ? Panel->panel : NULL;
  do
    p = panel_below (p);
  while (p && !panel_userptr (p));
  return p ? (TPanel) panel_userptr (p) : NULL;
}

static TCursorShape GetAbsCursorPos (int *PosX, int *PosY, chtype *CharUnderCursor)
{
  int covered, x = 1, y = 1;
  TCursorShape shape;
  TPanel Panel, Panel2;
  for (Panel = crt_PanelBelow (NULL), shape = CursorIgnored;
       Panel && (shape = Panel->CursorShape) == CursorIgnored;
       Panel = crt_PanelBelow (Panel));
  if (Panel)
    {
      getyx (Panel->w, y, x);
      x += Panel->WindXMin;
      y += Panel->WindYMin;
      for (covered = 0, Panel2 = crt_PanelAbove (Panel); !covered && Panel2; Panel2 = crt_PanelAbove (Panel2))
        if (x >= Panel2->WindXMin && x <= Panel2->WindXMax &&
            y >= Panel2->WindYMin && y <= Panel2->WindYMax) covered = 1;
      if (covered) shape = CursorHidden;
      if (CharUnderCursor) *CharUnderCursor = winch (Panel->w);
    }
  if (shape == CursorIgnored) shape = CursorHidden;
  *PosX = x - 1;
  *PosY = y - 1;
  return shape;
}

static void crt_UpdateInternal ()
{
  int x, y;
  TCursorShape shape;
  if (crt_ScreenSizeChanged || crt_ShutDown) return;
  #ifdef XCURSES
  crt_ShutDownJumpActive = TRUE;
  if (setjmp (crt_ShutDownJump))
    return;
  #endif
  shape = GetAbsCursorPos (&x, &y, NULL);
  update_panels ();
  if (shape != crt_LastShape)
    {
      crt_LastShape = shape;
      curs_set ((shape == CursorHidden) ? crt_CursorShapeHidden :
                (shape == CursorNormal) ? crt_CursorShapeNormal :
                                          crt_CursorShapeFull);
    }
  if (shape == CursorHidden)
    {
      SETCURSOR (0, 0);
      wmove (stdscr, 0, 0);
    }
  else
    {
      SETCURSOR (x, y);
      wmove (stdscr, y, x);
    }
  doupdate ();
  #ifdef XCURSES
  crt_ShutDownJumpActive = FALSE;
  #endif
}

/* Must be re-entrant! */
static void crt_Refresh ()
{
  if (crt_RefreshInhibit == 0)
    {
      crt_RefreshInhibit++;
      crt_PendingRefresh = FALSE;
      crt_UpdateInternal ();
      (void) idlok (crt_ActivePanel->w, FALSE);
      crt_RefreshInhibit--;
    }
  else
    crt_RefreshFlag++;
}

static void crt_NeedRefresh ()
{
  crt_CheckCheckBreak ();
  if (crt_UpdateLevel >= UpdateAlways || crt_RefreshFlag)
    {
      crt_RefreshFlag = 0;
      crt_Refresh ();
    }
  else if (crt_UpdateLevel >= UpdateRegularly && !crt_PendingRefresh)
    {
      crt_PendingRefresh = TRUE;
      crt_ScheduleRefresh ();
    }
}

GLOBAL (void crt_SimulateBlockCursor (void))
{
  if (!crt_SimulateBlockCursorActive)
    {
      int x, y;
      chtype CharUnderCursor;
      if (GetAbsCursorPos (&x, &y, &CharUnderCursor) >= CursorFat)
        {
          crt_SimulateBlockCursorActive = TRUE;
          if (!crt_SimulateBlockCursorPanel)
            {
              WINDOW *w = newwin (1, 1, y, x);
              if (!w) DO_RETURN_ADDRESS (crt_Fatal (7));
              keypad (w, TRUE);
              leaveok (w, FALSE);
              crt_SimulateBlockCursorPanel = new_panel (w);
              set_panel_userptr (crt_SimulateBlockCursorPanel, NULL);
            }
          else
            move_panel (crt_SimulateBlockCursorPanel, y, x);
          mvwaddch (panel_window (crt_SimulateBlockCursorPanel), 0, 0,
            (crt_LinuxConsole ? (chBlock | A_ALTCHARSET) : ACS_BLOCK)
            | (CharUnderCursor & A_ATTRIBUTES & ~A_ALTCHARSET));
          show_panel (crt_SimulateBlockCursorPanel);
          top_panel (crt_SimulateBlockCursorPanel);
        }
    }
  else
    {
      crt_SimulateBlockCursorActive = FALSE;
      if (crt_SimulateBlockCursorPanel) hide_panel (crt_SimulateBlockCursorPanel);
    }
  crt_NeedRefresh ();
}

GLOBAL (void crt_SimulateBlockCursorOff (void))
{
  if (crt_SimulateBlockCursorActive) crt_SimulateBlockCursor ();
}

GLOBAL (void crt_PanelHide (TPanel Panel))
{
  if (CheckPanel (Panel) && !Panel->Hidden)
    {
      crt_RefreshInhibit++;
      hide_panel (Panel->panel);
      Panel->Hidden = TRUE;
      crt_RefreshInhibit--;
      crt_NeedRefresh ();
    }
}

GLOBAL (void crt_PanelShow (TPanel Panel))
{
  if (CheckPanel (Panel) && Panel->Hidden)
    {
      crt_RefreshInhibit++;
      show_panel (Panel->panel);
      Panel->Hidden = FALSE;
      crt_RefreshInhibit--;
      crt_NeedRefresh ();
    }
}

GLOBAL (Boolean crt_PanelHidden (TPanel Panel))
{
  return CheckPanel (Panel) && Panel->Hidden;
}

GLOBAL (void crt_PanelTop (TPanel Panel))
{
  if (!CheckPanel (Panel)) return;
  if (Panel->Hidden) crt_PanelShow (Panel);
  crt_RefreshInhibit++;
  top_panel (Panel->panel);
  crt_RefreshInhibit--;
  crt_NeedRefresh ();
}

GLOBAL (void crt_PanelBottom (TPanel Panel))
{
  if (!CheckPanel (Panel)) return;
  if (Panel->Hidden) crt_PanelShow (Panel);
  crt_RefreshInhibit++;
  bottom_panel (Panel->panel);
  crt_RefreshInhibit--;
  crt_NeedRefresh ();
}

GLOBAL (void crt_PanelMoveAbove (TPanel Panel, TPanel Above))
{
  if (!CheckPanel (Panel)) return;
  if (!CheckPanel (Above))
    crt_PanelBottom (Panel);
  else if (Above->Hidden)
    crt_PanelHide (Panel);
  else if (Above != Panel)
    {
      PANEL *p, *p2;
      if (Panel->Hidden) crt_PanelShow (Panel);
      crt_RefreshInhibit++;
      top_panel (Panel->panel);
      p = panel_above (Above->panel);
      while (p && p != Panel->panel)
        {
          p2 = panel_above (p);
          top_panel (p);
          p = p2;
        }
      crt_RefreshInhibit--;
      crt_NeedRefresh ();
    }
}

GLOBAL (void crt_PanelMoveBelow (TPanel Panel, TPanel Below))
{
  if (!CheckPanel (Panel)) return;
  if (!CheckPanel (Below))
    crt_PanelTop (Panel);
  else if (Below->Hidden)
    crt_PanelHide (Panel);
  else if (Below != Panel)
    {
      PANEL *p, *p2;
      if (Panel->Hidden) crt_PanelShow (Panel);
      crt_RefreshInhibit++;
      bottom_panel (Panel->panel);
      p = panel_below (Below->panel);
      while (p && p != Panel->panel)
        {
          p2 = panel_below (p);
          bottom_panel (p);
          p = p2;
        }
      crt_RefreshInhibit--;
      crt_NeedRefresh ();
    }
}

GLOBAL (void crt_PanelBindToBackground (TPanel Panel, Boolean BindToBackground))
{
  if (CheckPanel (Panel)) Panel->BoundToBackground = BindToBackground;
}

GLOBAL (Boolean crt_PanelIsBoundToBackground (TPanel Panel))
{
  return CheckPanel (Panel) && Panel->BoundToBackground;
}

static WINDOW *crt_NewWin (int x1, int y1, int x2, int y2, Boolean BoundToBackground)
{
  int xsize = x2 - x1 + 1, ysize = y2 - y1 + 1;
  WINDOW *w = newwin (ysize, xsize, y1 - 1, x1 - 1);
  if (!w) DO_RETURN_ADDRESS (crt_Fatal (7));
  if (BoundToBackground)
    {
      chtype Buffer[xsize + 1];
      int yc;
      for (yc = 0; yc < ysize; yc++)
        {
          mvwinchnstr (stdscr, yc + y1 - 1, x1 - 1, Buffer, xsize);
          mvwaddchnstr (w, yc, 0, Buffer, xsize);
        }
    }
  keypad (w, TRUE);
  leaveok (w, FALSE);
  crt_LastShape = -1;
  return w;
}

/* Save contents of the panel to stdscr to imitate BP behaviour */
static void savetostdscr (TPanel Panel)
{
  if (Panel->BoundToBackground)
    {
      PANEL *panel;
      int yc,
          XMin  = Panel->WindXMin - 1,
          YMin  = Panel->WindYMin - 1,
          XSize = Panel->WindXMax - XMin,
          YSize = Panel->WindYMax - YMin;
      chtype Buffer[XSize + 1];
      for (yc = 0; yc < YSize; yc++)
        {
          mvwinchnstr (Panel->w, yc, 0, Buffer, XSize);
          mvwaddchnstr (stdscr, yc + YMin, XMin, Buffer, XSize);
        }
      wnoutrefresh (stdscr);
      for (panel = panel_above (NULL); panel; panel = panel_above (panel))
        touchwin (panel_window (panel));
    }
}

static void crt_DoSetScroll ()
{
  scrollok (crt_ActivePanel->w, crt_ActivePanel->ScrollState);
}

static void crt_UpdateCursorPos ()
{
  getyx (crt_ActivePanel->w, crt_Cursor.y, crt_Cursor.x);
}

static inline int combine_bytes (int lo, int hi)
{
  return  ((lo > 254) ? 254 : lo) +
         (((hi > 254) ? 254 : hi) << 8);
}

static void SetWindow (TPanel p, int x1, int y1, int x2, int y2)
{
  p->WindXMin = x1;
  p->WindYMin = y1;
  p->WindXMax = x2;
  p->WindYMax = y2;
  p->LastWindMin = combine_bytes (x1 - 1, y1 - 1);
  p->LastWindMax = combine_bytes (x2 - 1, y2 - 1);
}

static void crt_UpdateDataToActivePanel ()
{
  if (crt_ActivePanel)
    crt_ActivePanel->TextAttr = crt_TextAttr;
}

static void crt_UpdateDataFromActivePanel ()
{
  if (crt_ActivePanel)
    {
      crt_TextAttr = crt_ActivePanel->TextAttr;
      crt_WindMin = combine_bytes (crt_ActivePanel->WindXMin - 1, crt_ActivePanel->WindYMin - 1);
      crt_WindMax = combine_bytes (crt_ActivePanel->WindXMax - 1, crt_ActivePanel->WindYMax - 1);
      crt_UpdateCursorPos ();
    }
}

static void change_win (int x1, int y1, int x2, int y2)
{
  int x, y;
  WINDOW *oldwin = crt_ActivePanel->w;
  crt_RefreshInhibit++;
  if (x2 < 1) x2 = 1; if (x2 > crt_ScreenSize.x) x2 = crt_ScreenSize.x;
  if (y2 < 1) y2 = 1; if (y2 > crt_ScreenSize.y) y2 = crt_ScreenSize.y;
  if (x1 < 1) x1 = 1; if (x1 > x2) x1 = x2;
  if (y1 < 1) y1 = 1; if (y1 > y2) y1 = y2;
  getyx (crt_ActivePanel->w, y, x);
  x += crt_ActivePanel->WindXMin;
  y += crt_ActivePanel->WindYMin;
  savetostdscr (crt_ActivePanel);
  crt_ActivePanel->w = crt_NewWin (x1, y1, x2, y2, crt_ActivePanel->BoundToBackground);
  replace_panel (crt_ActivePanel->panel, crt_ActivePanel->w);
  delwin (oldwin);
  crt_LastShape = -1;
  crt_DoSetScroll ();
  if (x < x1) x = x1;
  if (x > x2) x = x2;
  if (y < y1) y = y1;
  if (y > y2) y = y2;
  wmove (crt_ActivePanel->w, y - y1, x - x1);
  SetWindow (crt_ActivePanel, x1, y1, x2, y2);
  crt_WindMin = crt_ActivePanel->LastWindMin;
  crt_WindMax = crt_ActivePanel->LastWindMax;
  crt_RefreshInhibit--;
  crt_UpdateCursorPos ();
  crt_NeedRefresh ();
}

static void crt_PanelActivate_Internal (TPanel Panel)
{
  if (!CheckPanel (Panel)) DO_RETURN_ADDRESS (crt_Fatal (5));
  if (Panel == crt_ActivePanel) return;
  crt_UpdateDataToActivePanel ();
  crt_ActivePanel = Panel;
  crt_UpdateDataFromActivePanel ();
}

static void crt_PanelNew_Internal (int x1, int y1, int x2, int y2, Boolean BindToBackground)
{
  TPanel NewPanel = malloc (sizeof (TPanelData));
  crt_RefreshInhibit++;
  NewPanel->Next = crt_PanelList;
  crt_PanelList = NewPanel;
  if (x2 < 1) x2 = 1; if (x2 > crt_ScreenSize.x) x2 = crt_ScreenSize.x;
  if (y2 < 1) y2 = 1; if (y2 > crt_ScreenSize.y) y2 = crt_ScreenSize.y;
  if (x1 < 1) x1 = 1; if (x1 > x2) x1 = x2;
  if (y1 < 1) y1 = 1; if (y1 > y2) y1 = y2;
  NewPanel->BoundToBackground = BindToBackground;
  NewPanel->Hidden = FALSE;
  NewPanel->ScrollState     = crt_ActivePanel ? crt_ActivePanel->ScrollState     : TRUE;
  NewPanel->PCCharSet       = crt_ActivePanel ? crt_ActivePanel->PCCharSet       : crt_PCCharSet;
  NewPanel->UseControlChars = crt_ActivePanel ? crt_ActivePanel->UseControlChars : TRUE;
  NewPanel->CursorShape     = crt_ActivePanel ? crt_ActivePanel->CursorShape     : CursorNormal;
  NewPanel->TextAttr        = crt_TextAttr;
  NewPanel->w = crt_NewWin (x1, y1, x2, y2, NewPanel->BoundToBackground);
  NewPanel->panel = new_panel (NewPanel->w);
  set_panel_userptr (NewPanel->panel, (void *) NewPanel);
  SetWindow (NewPanel, x1, y1, x2, y2);
  crt_PanelActivate_Internal (NewPanel);
  wmove (NewPanel->w, 0, 0);
  crt_UpdateCursorPos ();
  crt_DoSetScroll ();
  crt_RefreshInhibit--;
}

static void crt_GetLastMode ()
{
  if (crt_HasColors)
    {
      crt_LastMode = 0;
      if (crt_ColorFlag)          crt_LastMode += 1;
      if (crt_ScreenSize.x >= 80) crt_LastMode += 2;
    }
  else
    crt_LastMode = 7;
  if (crt_ScreenSize.y >= 43) crt_LastMode += 0x100;
  crt_IsMonochrome = !crt_HasColors || !crt_ColorFlag;
}

static int crt_Attr2CursAttr (TTextAttr attr)
{
  #ifdef XCURSES
  /* PDCurses under X has serious problems writing black on black. :-(
     So we write some other color on black and output spaces (see chtransform()) */
  if ((attr & ~0x88) == 0) attr = 7;
  #endif
  return (crt_ColorFlag ? crt_Attrs : crt_MonoAttrs)[attr & 7][(attr >> 4) & 7] |
         (((attr & 8) && (crt_ColorFlag || (attr & 0x77))) ? A_BOLD : 0) |
         ((attr & 0x80) ? A_BLINK : 0);
}

static void crt_RawOut (Boolean flag UNUSED)
{
  #ifdef HAVE_RAW_OUTPUT
  raw_output (flag);
  #endif
}

static void crt_SetTypeAhead ()
{
  typeahead ((crt_UpdateLevel == UpdateWaitInput) ? crt_Get_Input_FD () : -1);
}

GLOBAL (void crt_SavePreviousScreen (Boolean On))
{
  if (!On)
    crt_SavePreviousScreenFlag = -3;
  else if (crt_SavePreviousScreenFlag < 0)
    crt_SavePreviousScreenFlag = crt_SaveRestoreScreen (FALSE);
}

GLOBAL (Boolean crt_SavePreviousScreenWorks (void))
{
  if (crt_SavePreviousScreenFlag == -1)
    crt_SavePreviousScreenFlag = crt_SaveRestoreScreen (FALSE);
  return crt_SavePreviousScreenFlag > 0;
}

GLOBAL (void crt_Init (void))
{
  int fg, bg, c, cursattr;
  #ifdef USE_NCURSES
  FILE *crt_FileOut = NULL, *crt_FileIn = NULL;
  #endif
  if (crt_Inited) return;
  SAVE_RETURN_ADDRESS;
  #ifdef XCURSES
  #ifdef SIGINT
  /* If we want to suppress Ctrl-C from the controlling terminal,
     we have to do it now before PDCurses forks in initscr(). */
  if (!crt_CheckBreak) signal (SIGINT, SIG_IGN);
  #endif
  XCursesProgramName = crt_GetProgramName ();
  #endif
  crt_ScreenSizeChanged = FALSE;
  #ifndef USE_NCURSES
  crt_OutputFD = fileno (stdout);
  crt_InputFD = fileno (stdin);
  #else
  if (crt_OutputFD < 0)
    crt_OutputFD = fileno (stdout);
  else if (!(crt_FileOut = fdopen (crt_OutputFD, "w")))
    crt_Fatal (1);
  if (crt_InputFD < 0)
    crt_InputFD = fileno (stdin);
  else if (!(crt_FileIn = fdopen (crt_InputFD, "r")))
    {
      if (crt_FileOut) fclose (crt_FileOut);
      crt_Fatal (1);
    }
  if (crt_Terminal || crt_FileIn || crt_FileOut)
    {
      char *value_str, *value_end;
      int value;
      if (!newterm (crt_Terminal, crt_FileOut ? crt_FileOut : stdout, crt_FileIn ? crt_FileIn : stdin))
        crt_Fatal (2);
      if ((value_str = getenv ("ESCDELAY")) &&
          (value = strtol (value_str, &value_end, 10)) >= 0 && (!value_end || !*value_end))
        ESCDELAY = value;
      def_prog_mode ();
    }
  else
  #endif
    if (!initscr ()) crt_Fatal (1);
  crt_DummyPad = newpad (1, 1);
  #ifdef XCURSES
  sleep (1);  /* @@There is a problem with XCurses not always starting up
                 correctly (race condition?). Until it is solved, this
                 sleep() is an ugly and unreliable way to avoid it
                 sometimes ... */
  #endif
  #ifdef USE_PDCURSES
  PDC_save_key_modifiers (TRUE);
  #else
  crt_LinuxConsole = strncmp (termname (), "linux", 5) == 0;
  /* Work-around for the problem that ncurses ignores the A_BOLD attribute
     when clearing which may cause a wrong cursor color. */
  if (crt_LinuxConsole)
    back_color_erase = 0;
  if (crt_SavePreviousScreenFlag == -3)
    {
      if (isprivate (enter_ca_mode)) enter_ca_mode = NULL;
      if (isprivate (exit_ca_mode)) exit_ca_mode = NULL;
    }
  #endif
  #if !defined (USE_PDCURSES) || defined (XCURSES)
  chars_0_31[ 4] = ACS_DIAMOND;
  chars_0_31[16] = ACS_RARROW;
  chars_0_31[17] = ACS_LARROW;
  chars_0_31[18] = ACS_VLINE;
  chars_0_31[22] = ACS_S9;
  chars_0_31[23] = ACS_DARROW;
  chars_0_31[24] = ACS_UARROW;
  chars_0_31[25] = ACS_DARROW;
  chars_0_31[26] = ACS_RARROW;
  chars_0_31[27] = ACS_LARROW;
  chars_0_31[28] = ACS_LLCORNER;
  chars_0_31[29] = ACS_HLINE;
  chars_0_31[30] = ACS_UARROW;
  chars_0_31[31] = ACS_DARROW;
  chars_128_255[ 28] = ACS_STERLING;
  chars_128_255[ 38] = ACS_DEGREE;
  chars_128_255[ 39] = ACS_DEGREE;
  chars_128_255[ 41] = ACS_ULCORNER;
  chars_128_255[ 42] = ACS_URCORNER;
  chars_128_255[ 46] = ACS_LARROW;
  chars_128_255[ 47] = ACS_RARROW;
  chars_128_255[ 48] = ACS_CKBOARD;
  chars_128_255[ 49] = ACS_CKBOARD;
  chars_128_255[ 50] = ACS_CKBOARD;
  chars_128_255[ 51] = ACS_VLINE;
  chars_128_255[ 52] = ACS_RTEE;
  chars_128_255[ 53] = ACS_RTEE;
  chars_128_255[ 54] = ACS_RTEE;
  chars_128_255[ 55] = ACS_URCORNER;
  chars_128_255[ 56] = ACS_URCORNER;
  chars_128_255[ 57] = ACS_RTEE;
  chars_128_255[ 58] = ACS_VLINE;
  chars_128_255[ 59] = ACS_URCORNER;
  chars_128_255[ 60] = ACS_LRCORNER;
  chars_128_255[ 61] = ACS_LRCORNER;
  chars_128_255[ 62] = ACS_LRCORNER;
  chars_128_255[ 63] = ACS_URCORNER;
  chars_128_255[ 64] = ACS_LLCORNER;
  chars_128_255[ 65] = ACS_BTEE;
  chars_128_255[ 66] = ACS_TTEE;
  chars_128_255[ 67] = ACS_LTEE;
  chars_128_255[ 68] = ACS_HLINE;
  chars_128_255[ 69] = ACS_PLUS;
  chars_128_255[ 70] = ACS_LTEE;
  chars_128_255[ 71] = ACS_LTEE;
  chars_128_255[ 72] = ACS_LLCORNER;
  chars_128_255[ 73] = ACS_ULCORNER;
  chars_128_255[ 74] = ACS_BTEE;
  chars_128_255[ 75] = ACS_TTEE;
  chars_128_255[ 76] = ACS_LTEE;
  chars_128_255[ 77] = ACS_HLINE;
  chars_128_255[ 78] = ACS_PLUS;
  chars_128_255[ 79] = ACS_BTEE;
  chars_128_255[ 80] = ACS_BTEE;
  chars_128_255[ 81] = ACS_TTEE;
  chars_128_255[ 82] = ACS_TTEE;
  chars_128_255[ 83] = ACS_LLCORNER;
  chars_128_255[ 84] = ACS_LLCORNER;
  chars_128_255[ 85] = ACS_ULCORNER;
  chars_128_255[ 86] = ACS_ULCORNER;
  chars_128_255[ 87] = ACS_PLUS;
  chars_128_255[ 88] = ACS_PLUS;
  chars_128_255[ 89] = ACS_LRCORNER;
  chars_128_255[ 90] = ACS_ULCORNER;
  chars_128_255[ 91] = ACS_BLOCK;
  chars_128_255[ 92] = ACS_BLOCK;
  chars_128_255[ 93] = ACS_BLOCK;
  chars_128_255[ 94] = ACS_BLOCK;
  chars_128_255[ 95] = ACS_BLOCK;
  chars_128_255[ 99] = ACS_PI;
  chars_128_255[113] = ACS_PLMINUS;
  chars_128_255[114] = ACS_GEQUAL;
  chars_128_255[115] = ACS_LEQUAL;
  chars_128_255[120] = ACS_DEGREE;
  chars_128_255[126] = ACS_BULLET;
  #endif
  cbreak ();
  noecho ();
  scrollok (stdscr, TRUE);
  crt_RawOut (TRUE);
  crt_ColorFlag = crt_HasColors = has_colors ();
  if (crt_HasColors)
    {
      start_color ();
      c = 0;
      for (bg = 0; bg < 8; bg++)
        for (fg = 0; fg < 8; fg++)
          if (INVIS_WORKS && bg == fg && bg > 0)
            crt_Attrs[fg][bg] = crt_Attrs[0][bg] | A_INVIS;
          else if (REVERSE_WORKS && fg < bg)
            crt_Attrs[fg][bg] = crt_Attrs[bg][fg] | A_REVERSE;
          else
            {
              if (init_pair (++c, crt_Colors[fg], crt_Colors[bg]) == ERR)
                {
                  fprintf (stderr, "could not create color pair (%i,%i)", fg, bg);
                  #ifdef XCURSES
                  XCursesExit ();
                  #endif
                  exit (1);
                }
              crt_Attrs[fg][bg] = COLOR_PAIR (c);
            }
      for (bg = 0; bg < 8; bg++)
        for (fg = 0; fg < 8; fg++)
          crt_MonoAttrs[fg][bg] = crt_Attrs[7][0];
      crt_MonoAttrs[0][0] = crt_Attrs[0][0];
      crt_MonoAttrs[1][0] = crt_Attrs[1][0];
      crt_MonoAttrs[0][7] = crt_Attrs[0][7];
    }
  else
    {
      for (bg = 0; bg < 8; bg++)
        for (fg = 0; fg < 8; fg++)
          crt_MonoAttrs[fg][bg] = A_NORMAL;
      crt_MonoAttrs[0][0] = A_INVIS;
      crt_MonoAttrs[1][0] = A_UNDERLINE;
      crt_MonoAttrs[0][7] = A_REVERSE;
    }
  cursattr = crt_Attr2CursAttr (crt_NormAttr);
  attrset (cursattr);
  bkgdset (cursattr);
  erase ();
  crt_InitSignals ();
  keypad (stdscr, TRUE);
  getmaxyx (stdscr, crt_ScreenSize.y, crt_ScreenSize.x);
  wrefresh (stdscr);  /* prevents flickering at the beginning of XCurses programs */
  crt_GetLastMode ();
  crt_PanelNew_Internal (1, 1, crt_ScreenSize.x, crt_ScreenSize.y, TRUE);
  typeahead (-1);
  crt_SetTypeAhead ();
  crt_RegisterRestoreTerminal ();
  crt_Inited = 1;
  RESTORE_RETURN_ADDRESS;
}

static void crt_BPAutoInit ()
{
  static Boolean initializing = FALSE;
  if (initializing)  /* in case crt_AutoInitProc causes CRT to auto init again ... */
    initializing = FALSE;
  else
    {
      initializing = TRUE;
      if (crt_AutoInitProc) (*crt_AutoInitProc) ();
      if (!initializing) return;
      initializing = FALSE;
    }
  crt_PCCharSet = TRUE;
  if (!crt_UpdateLevelChanged) crt_UpdateLevel = UpdateRegularly;
  crt_Init ();
}

static void adjust_size (int *x1, int *y1, int *x2, int *y2, TPoint LastScreenSize)
{
  if (*x2 > crt_ScreenSize.x)
    {
      *x1 -= *x2 - crt_ScreenSize.x;
      if (*x1 < 1) *x1 = 1;
      *x2 = crt_ScreenSize.x;
    }
  else if (*x1 == 1 && *x2 == LastScreenSize.x)
    *x2 = crt_ScreenSize.x;
  if (*y2 > crt_ScreenSize.y)
    {
      *y1 -= *y2 - crt_ScreenSize.y;
      if (*y1 < 1) *y1 = 1;
      *y2 = crt_ScreenSize.y;
    }
  else if (*y1 == 1 && *y2 == LastScreenSize.y)
    *y2 = crt_ScreenSize.y;
}

static void adjust_panel (PANEL *panel, WINDOW **w, int x1, int y1, int x2, int y2)
{
  int x, y, xsize = x2 - x1 + 1, ysize = y2 - y1 + 1;
  WINDOW *new;
  /* It's not very clear what has to be updated in the windows and
     panels, and in which order (in the different curses libraries).
     So, we rather do too much than too little. First resize, then
     move, otherwise the move could fail, because the window might
     not fit on the screen. */
  getyx ((*w), y, x);
  new = resize_window ((*w), ysize, xsize);
  if (new) *w = new;
  panel->win = *w;
  replace_panel (panel, (*w));
  move_panel (panel, y1 - 1, x1 - 1);
  if (x >= xsize) x = xsize - 1;
  if (y >= ysize) y = ysize - 1;
  wmove ((*w), y, x);
  keypad ((*w), TRUE);
  leaveok ((*w), FALSE);
}

GLOBAL (void crt_Check_WinChanged (void))
{
  SAVE_RETURN_ADDRESS;
  if (!crt_Inited) crt_BPAutoInit ();
  #ifdef USE_PDCURSES
  /* In XCurses, this wouldn't be necessary (but doesn't hurt)
     because the program will get a SIGWINCH, but e.g. under mingw,
     it doesn't get a SIGWINCH, so we need this additional check. */
  if (is_termresized ()) crt_ScreenSizeChanged = TRUE;
  #endif
  if (crt_ScreenSizeChanged)
    {
      PANEL *panel;
      TPanel p;
      TPoint LastScreenSize;
      crt_RefreshInhibit++;
      #ifdef USE_PDCURSES
      /* XCurses: resize the terminal after the user resized the window */
      if (is_termresized ()) resize_term (0, 0);
      /* work around a bug in the PDCurses panel library */
      {
        extern PANEL __stdscr_pseudo_panel;
        __stdscr_pseudo_panel.win = stdscr;
        __stdscr_pseudo_panel.wendy = LINES;
        __stdscr_pseudo_panel.wendx = COLS;
      }
      #endif
      napms (100);  /* wait for a new unimap to be loaded if necessary */
      /* The following code is a bit tricky ...
         doupdate() will update the screen size in ncurses, but the
         size or position of any window may have become invalid, so
         they must not be updated now! */
      untouchwin (stdscr);
      for (panel = panel_above (NULL); panel; panel = panel_above (panel))
        untouchwin (panel_window (panel));
      if (!crt_ShutDown)
        doupdate ();
      LastScreenSize = crt_ScreenSize;
      getmaxyx (stdscr, crt_ScreenSize.y, crt_ScreenSize.x);
      /* Resize all CRT panels */
      for (p = crt_PanelList; p; p = p->Next)
        {
          Boolean SetWinMinMax = p == crt_ActivePanel
                                 && crt_WindMin == p->LastWindMin
                                 && crt_WindMax == p->LastWindMax;
          int x1, y1, x2, y2;
          x1 = p->WindXMin;
          y1 = p->WindYMin;
          x2 = p->WindXMax;
          y2 = p->WindYMax;
          adjust_size (&x1, &y1, &x2, &y2, LastScreenSize);
          if (x1 != p->WindXMin || y1 != p->WindYMin ||
              x2 != p->WindXMax || y2 != p->WindYMax)
            {
              p->WindXMin = x1;
              p->WindYMin = y1;
              p->WindXMax = x2;
              p->WindYMax = y2;
              SetWindow (p, x1, y1, x2, y2);
              if (SetWinMinMax)
                {
                  crt_WindMin = p->LastWindMin;
                  crt_WindMax = p->LastWindMax;
                }
              adjust_panel (p->panel, &p->w, x1, y1, x2, y2);
              if (p->Hidden) hide_panel (p->panel);
            }
        }
      /* Handle panels that don't belong to CRT windows (e.g., the one
         for the simulated block cursor) */
      for (panel = panel_above (NULL); panel; panel = panel_above (panel))
        if (!panel_userptr (panel))
          {
            WINDOW *w = panel_window (panel);
            int x1, y1, x2, y2, xsize, ysize, oldx1, oldy1, oldx2, oldy2;
            getbegyx (w, y1, x1);
            x1++;
            y1++;
            getmaxyx (w, ysize, xsize);
            oldx1 = x1;
            oldy1 = y1;
            oldx2 = x2 = x1 + xsize - 1;
            oldy2 = y2 = y1 + ysize - 1;
            adjust_size (&x1, &y1, &x2, &y2, LastScreenSize);
            if (x1 != oldx1 || y1 != oldy1 || x2 != oldx2 || y2 != oldy2)
              adjust_panel (panel, &w, x1, y1, x2, y2);
          }
      crt_UpdateCursorPos ();
      /* Now we can refresh everything */
      touchwin (stdscr);
      for (panel = panel_above (NULL); panel; panel = panel_above (panel))
        touchwin (panel_window (panel));
      /* Overcome ncurses' buffering of the cursor shape, because sometimes
         when the screen size is changed (e.g. by SVGATextMode), also the
         cursor shape is reset. */
      curs_set (1);
      curs_set (0);
      crt_LastShape = CursorHidden;
      crt_DoSetScroll ();
      crt_UpdateInternal ();
      crt_ScreenSizeChanged = FALSE;
      crt_GetLastMode ();
      crt_RefreshInhibit--;
      if (crt_KeyBuf == 0) crt_KeyBuf = KEY_RESIZE;
    }
  if (crt_WindMin != crt_ActivePanel->LastWindMin || crt_WindMax != crt_ActivePanel->LastWindMax)
    change_win ((crt_WindMin & 0xff) + 1, (crt_WindMin >> 8) + 1,
                (crt_WindMax & 0xff) + 1, (crt_WindMax >> 8) + 1);
  RESTORE_RETURN_ADDRESS;
}

GLOBAL (void crt_GotoXY (int x, int y))
{
  DO_CRT_CHECK_WINCHANGED;
  wmove (crt_ActivePanel->w, y - 1, x - 1);
  crt_Cursor.x = x - 1;
  crt_Cursor.y = y - 1;
  crt_NeedRefresh ();
}

GLOBAL (int crt_WhereX (void))
{
  int x, y;
  DO_CRT_CHECK_WINCHANGED;
  getyx (crt_ActivePanel->w, y, x);
  return x + 1;
}

GLOBAL (int crt_WhereY (void))
{
  int x, y;
  DO_CRT_CHECK_WINCHANGED;
  getyx (crt_ActivePanel->w, y, x);
  return y + 1;
}

GLOBAL (void crt_Window (int x1, int y1, int x2, int y2))
{
  DO_CRT_CHECK_WINCHANGED;
  if (x1 >= 1 && x1 <= x2 && x2 <= crt_ScreenSize.x &&
      y1 >= 1 && y1 <= y2 && y2 <= crt_ScreenSize.y)
    {
      change_win (x1, y1, x2, y2);
      crt_GotoXY (1, 1);
    }
}

GLOBAL (void crt_CGetWindow (int *x1, int *y1, int *x2, int *y2))
{
  DO_CRT_CHECK_WINCHANGED;
  if (x1) *x1 = crt_ActivePanel->WindXMin;
  if (y1) *y1 = crt_ActivePanel->WindYMin;
  if (x2) *x2 = crt_ActivePanel->WindXMax;
  if (y2) *y2 = crt_ActivePanel->WindYMax;
}

GLOBAL (void crt_SetScroll (Boolean state))
{
  DO_CRT_CHECK_WINCHANGED;
  crt_ActivePanel->ScrollState = state;
  crt_DoSetScroll ();
}

GLOBAL (Boolean crt_GetScroll (void))
{
  DO_CRT_CHECK_WINCHANGED;
  return crt_ActivePanel->ScrollState;
}

GLOBAL (void crt_SetCursorShape (TCursorShape shape))
{
  DO_CRT_CHECK_WINCHANGED;
  crt_ActivePanel->CursorShape = shape;
  crt_NeedRefresh ();
}

GLOBAL (TCursorShape crt_GetCursorShape (void))
{
  DO_CRT_CHECK_WINCHANGED;
  return crt_ActivePanel->CursorShape;
}

GLOBAL (TPanel crt_GetActivePanel (void))
{
  DO_CRT_CHECK_WINCHANGED;
  return crt_ActivePanel;
}

GLOBAL (void crt_PanelActivate (TPanel Panel))
{
  if (Panel == crt_ActivePanel) return;
  DO_CRT_CHECK_WINCHANGED;
  DO_RETURN_ADDRESS (crt_PanelActivate_Internal (Panel));
}

GLOBAL (void crt_PanelNew (int x1, int y1, int x2, int y2, Boolean BindToBackground))
{
  DO_CRT_CHECK_WINCHANGED;
  DO_RETURN_ADDRESS (crt_PanelNew_Internal (x1, y1, x2, y2, BindToBackground));
  crt_NeedRefresh ();
}

GLOBAL (void crt_PanelDelete (TPanel Panel))
{
  TPanel *PList = &crt_PanelList;
  while (*PList && *PList != Panel) PList = &((*PList)->Next);
  if (!*PList) DO_RETURN_ADDRESS (crt_Fatal (3));
  DO_CRT_CHECK_WINCHANGED;
  crt_RefreshInhibit++;
  *PList = Panel->Next;
  if (!crt_PanelList) DO_RETURN_ADDRESS (crt_Fatal (4));
  savetostdscr (Panel);
  del_panel (Panel->panel);
  delwin (Panel->w);
  free (Panel);
  if (Panel == crt_ActivePanel)
    {
      crt_ActivePanel = NULL;
      crt_PanelActivate_Internal (crt_PanelList);
    }
  crt_LastShape = -1;
  crt_RefreshInhibit--;
  crt_NeedRefresh ();
}

static TTextAttr cursattr2attr (int cursattr)
{
  int attr = 0;
  cursattr &= (A_ATTRIBUTES & ~A_ALTCHARSET);
  if (crt_Attr2CursAttr (crt_NormAttr) == cursattr) return crt_NormAttr;
  while (attr < 0x100 && crt_Attr2CursAttr (attr) != cursattr) attr++;
  return (attr == 0x100) ? crt_NormAttr : attr;
}

static void crt_SetAttr ()
{
  int cursattr;
  DO_CRT_CHECK_WINCHANGED;
  cursattr = crt_Attr2CursAttr (crt_TextAttr);
  wattrset (crt_ActivePanel->w, cursattr);
  wbkgdset (crt_ActivePanel->w, cursattr | ' ');
}

GLOBAL (void crt_Update (void))
{
  DO_CRT_CHECK_WINCHANGED;
  if (crt_UpdateLevel == UpdateRegularly) crt_StopRefresh ();
  typeahead (-1);
  crt_Refresh ();
  crt_SetTypeAhead ();
}

GLOBAL (void crt_Redraw (void))
{
  PANEL *panel;
  DO_CRT_CHECK_WINCHANGED;
  touchwin (stdscr);
  for (panel = panel_above (NULL); panel; panel = panel_above (panel))
    touchwin (panel_window (panel));
  clearok (curscr, TRUE);
  crt_LastShape = -1;
  crt_UpdateInternal ();
}

GLOBAL (void crt_SetUpdateLevel (TCRTUpdate level))
{
  if (crt_Inited)
    {
      DO_CRT_CHECK_WINCHANGED;
      if (crt_UpdateLevel == UpdateRegularly) crt_Update ();
    }
  crt_UpdateLevel = level;
  crt_UpdateLevelChanged = TRUE;
  if (crt_Inited) crt_SetTypeAhead ();
}

GLOBAL (void crt_Restore_Terminal_No_CRT (void))
{
  if (!crt_Inited || crt_TerminalNoCRT || crt_ShutDown) return;
  DO_CRT_CHECK_WINCHANGED;  /* We do need this here, otherwise the tputs in
                               crt_ClearTerminal() can cause a segfault. */
  if (crt_ActivePanel) DO_RETURN_ADDRESS (crt_Update ());
  crt_TerminalNoCRT = TRUE;
  #ifdef USE_PDCURSES
  savetty ();
  #endif
  if (crt_ClearFlag)
    {
      #ifdef USE_NCURSES
      if (isprivate (enter_ca_mode))
        {
          crt_Save_enter_ca_mode = enter_ca_mode;
          enter_ca_mode = NULL;
        }
      if (isprivate (exit_ca_mode))
        {
          crt_Save_exit_ca_mode = exit_ca_mode;
          exit_ca_mode = NULL;
        }
      #endif
    }
  endwin ();
  #if defined (SIGTSTP) && !defined (XCURSES)
  signal (SIGTSTP, SIG_DFL);
  #endif
  if (crt_ClearFlag
      || (crt_SavePreviousScreenFlag > 0 && !(crt_ScreenRestored = crt_SaveRestoreScreen (TRUE) > 0))
      || crt_SavePreviousScreenFlag == 0)
    crt_ClearTerminal ();
}

GLOBAL (void crt_Restore_Terminal_CRT (void))
{
  if (crt_ShutDown) return;
  if (!crt_Inited || !crt_TerminalNoCRT) return;
  crt_ScreenSizeChanged = TRUE;  /* we don't get a SIGWINCH if the terminal was resized while we were in the background */
  if (crt_ScreenRestored)
    {
      crt_ScreenRestored = FALSE;
      crt_SaveRestoreScreen (FALSE);
    }
  DO_CRT_CHECK_WINCHANGED;
  #ifdef USE_PDCURSES
  resetty ();
  SETCURSOR (0, 0); doupdate ();  /* @@ resetty() seems to get the cursor position wrong */
  #endif
  #if defined (SIGTSTP) && !defined (XCURSES)
  signal (SIGTSTP, &tstp_handler);
  #endif
  crt_RawOut (TRUE);
  clearok (curscr, TRUE);
  crt_LastShape = -1;
  crt_UpdateInternal ();
  #ifdef USE_NCURSES
  if (crt_Save_enter_ca_mode) enter_ca_mode = crt_Save_enter_ca_mode;
  if (crt_Save_exit_ca_mode) exit_ca_mode = crt_Save_exit_ca_mode;
  crt_Save_enter_ca_mode = crt_Save_exit_ca_mode = NULL;
  #endif
  #ifdef USE_PDCURSES
  PDC_save_key_modifiers (TRUE);
  #endif
  crt_TerminalNoCRT = FALSE;
}

GLOBAL (void crt_Done (void))
{
  if (!crt_Inited || crt_ShutDown) return;
  if (crt_ActivePanel && !crt_TerminalNoCRT)
    {
      DO_RETURN_ADDRESS (crt_Update ());
      endwin ();
    }
  #ifdef USE_NCURSES
  if (crt_Save_exit_ca_mode) tputs (crt_Save_exit_ca_mode, 1, putch);
  crt_Save_enter_ca_mode = crt_Save_exit_ca_mode = NULL;
  #endif
  if (crt_SavePreviousScreenFlag > 0 && !crt_TerminalNoCRT)
    crt_SaveRestoreScreen (TRUE);
  crt_Inited = 0;
  #ifdef XCURSES
  XCursesExit ();
  #endif
}

GLOBAL (void crt_SetCursesMode (Boolean on))
{
  if (!crt_Inited || crt_ShutDown) return;
  if (on)
    {
      reset_prog_mode ();
      crt_RawOut (TRUE);
    }
  else
    {
      crt_RawOut (FALSE);
      reset_shell_mode ();
    }
}

GLOBAL (void crt_Delay (unsigned ms))
{
  DO_CRT_CHECK_WINCHANGED;
  crt_Update ();
  napms (ms);
}

static int get_ch (void)
{
  int i;
  if (crt_ShutDown)
    return KEY_HUP;
  #ifdef XCURSES
  crt_ShutDownJumpActive = TRUE;
  if (setjmp (crt_ShutDownJump))
    i = KEY_HUP;
  else
  #endif
    /* Use stdscr rather than crt_ActivePanel->w, so a non-top
       panel will not be redrawn. If the terminal is in non-CRT
       mode, use a dummy pad because a pad does *not* cause wgetch()
       to refresh(). Using the dummy pad in CRT mode does not work
       well for some reason (@@). */
    i = wgetch (crt_TerminalNoCRT ? crt_DummyPad : stdscr);
  #ifdef XCURSES
  crt_ShutDownJumpActive = FALSE;
  #endif
  return i;
}

static int wgetk ()
{
  int i = get_ch ();
  if (i == KEY_RESIZE) crt_ScreenSizeChanged = TRUE;
  if (crt_ScreenSizeChanged)
    {
      DO_CRT_CHECK_WINCHANGED;
      if (i != KEY_RESIZE && i != ERR) crt_KeyBuf = i;
      if (crt_KeyBuf == KEY_RESIZE) crt_KeyBuf = 0;
      i = KEY_RESIZE;
    }
  return i;
}

GLOBAL (void crt_Select (void *PrivateData UNUSED, Boolean *ReadSelect, Boolean *WriteSelect, Boolean *ExceptSelect))
{
  DO_CRT_CHECK_WINCHANGED;
  if (*ReadSelect)
    {
      if (crt_UpdateLevel == UpdateRegularly)
        {
          crt_StopRefresh ();
          crt_Refresh ();
        }
      (*ReadSelect) = !!(crt_UngetKeyBuf || crt_KeyBuf || crt_FKeyBuf || crt_ScreenSizeChanged);
    }
  if (crt_Get_Output_FD () >= 0) (*WriteSelect) = FALSE;
  (*ExceptSelect) = FALSE;
}

static Boolean crt_KeyPressedInternal ()
{
  int ch;
  crt_NoDelay (TRUE);
  ch = wgetk ();
  if (ch == ERR) return 0;
  crt_KeyBuf = ch;
  return 1;
}

GLOBAL (Boolean crt_KeyPressed (void))
{
  DO_CRT_CHECK_WINCHANGED;
  if (crt_UpdateLevel >= UpdateInput) crt_Update ();
  if (crt_UngetKeyBuf || crt_KeyBuf || crt_FKeyBuf) return 1;
  return crt_KeyPressedInternal ();
}

GLOBAL (void crt_SetScreenSize (int x, int y))
{
  DO_CRT_CHECK_WINCHANGED;
  crt_Update ();
  crt_ChangeScreenSize (x, y);
  crt_ScreenSizeChanged = TRUE;
  crt_SetAttr ();
  crt_Redraw ();
  crt_GetLastMode ();
  crt_KeyPressedInternal ();
  if (crt_KeyBuf == KEY_RESIZE) crt_KeyBuf = 0;
}

GLOBAL (void crt_SetMonochrome (Boolean Monochrome))
{
  DO_CRT_CHECK_WINCHANGED;
  crt_ColorFlag = crt_HasColors && !Monochrome;
  crt_SetAttr ();
  crt_Redraw ();
  crt_GetLastMode ();
}

GLOBAL (void crt_UngetCh (TKey ch))
{
  crt_UngetKeyBuf = ch;
}

static Char find_key (TKeyTable *table, int ch)
{
  while (table->CursesKey != 0 && table->CursesKey != ch) table++;
  return table->CRTKey;
}

/* Don't use toupper() since it messes up the function key codes */
static int upcase (int ch)
{
  if (ch >= 'a' && ch <= 'z')
    return ch - 'a' + 'A';
  else
    return ch;
}

GLOBAL (TKey crt_AltKey (Char ch))
{
  return 0x100 * find_key (EscKeyTable, upcase (ch));
}

GLOBAL (TKey crt_AltGrKey (Char ch))
{
  return 0x100 * find_key (AltGrKeyTable, upcase (ch));
}

GLOBAL (TKey crt_ExtraKey (Char ch))
{
  return 0x100 * find_key (ExtraKeyTable, upcase (ch));
}

GLOBAL (TKey crt_ReadKeyWord (void))
{
  int ch, chu, shiftstate;
  Char c, cs;
  (void) &ch;  /* don't put it into a register because of longjmp() */
  DO_CRT_CHECK_WINCHANGED;
  if (crt_UpdateLevel > UpdateWaitInput ||
      ((crt_UpdateLevel == UpdateWaitInput) &&
       !(crt_UngetKeyBuf || crt_KeyBuf || crt_KeyPressedInternal ())))
    crt_Update ();
  if (crt_UngetKeyBuf)
    {
      TKey k = crt_UngetKeyBuf;
      crt_UngetKeyBuf = 0;
      return k;
    }
  else if (crt_KeyBuf)
    {
      ch = crt_KeyBuf;
      crt_KeyBuf = 0;
      if (ch == KEY_RESIZE)
        {
          int i;
          crt_NoDelay (TRUE);
          i = get_ch ();
          if (i != KEY_RESIZE && i == ERR) crt_KeyBuf = i;
        }
    }
  else
    {
      int retry = 3;
      crt_NoDelay (FALSE);
      do
        {
          errno = 0;
          ch = wgetk ();
          if (crt_UngetKeyBuf)  /* may have been set via crt_UngetCh() by a handler for SIGINT etc. */
            {
              TKey k = crt_UngetKeyBuf;
              crt_UngetKeyBuf = 0;
              if (ch != ERR) crt_KeyBuf = ch;
              return k;
            }
        }
      while (ch == ERR && errno == 0 && retry--);
      if (ch == ERR)
        {
          if (crt_CheckBreak)
            DO_RETURN_ADDRESS (crt_Fatal (6));
          else
            return 0x100 * ksError;
        }
    }
  if (ch == KEY_HUP)
    return 0x100 * ksHUp;
  #ifndef USE_PDCURSES
  if (ch == chEsc)
    {
      crt_NoDelay (TRUE);
      ch = wgetk ();
      if (ch == ERR) return chEsc;
      c = find_key (EscKeyTable, upcase (ch));
      if (c != 0)
        return 0x100 * c;
      if (ch >= FKEY1 && ch <= FKEY1 + 9)
        return 0x100 * (ksAltF1 + ch - FKEY1);
      if (ch >= FKEY1 + 10 && ch <= FKEY1 + 11)
        return 0x100 * (ksAltF11 + ch - (FKEY1 + 10));
      crt_KeyBuf = ch;
      return chEsc;
    }
  #endif
  shiftstate = crt_GetShiftState ();
  /* Recognize Ctrl-Backspace before applying KeyTable, otherwise
     Ctrl-Backspace and Ctrl-H (= normal Backspace) could not be
     distinguished. */
  if ((shiftstate & shCtrl) && ch == KEY_BACKSPACE) return 0x100 * ksCtrlBkSp;
  if ((c = find_key (KeyTable, ch))) ch = c;
  chu = upcase (ch);
  if ((shiftstate & shShift) && (cs = find_key (ShiftKeyTable, chu))) return 0x100 * cs;
  if ((shiftstate & shAlt  ) && (cs = find_key (AltKeyTable  , chu))) return 0x100 * cs;
  if ((shiftstate & shAltGr) && (cs = find_key (AltGrKeyTable, chu))) return 0x100 * cs;
  if ((shiftstate & shExtra) && (cs = find_key (ExtraKeyTable, chu))) return 0x100 * cs;
  if (1 <= ch && ch <= 0xff) return ch;
  if (ch >= FKEY1 && ch <= FKEY1 + 9)
    {
      if (shiftstate & shAnyAlt)
        c = ksAltF1 + ch - FKEY1;
      else if (shiftstate & shCtrl)
        c = ksCtrlF1 + ch - FKEY1;
      else if (shiftstate & shShift)
        c = ksShF1 + ch - FKEY1;
      else
        c = ksF1 + ch - FKEY1;
    }
  else if (ch >= FKEY1 + 10 && ch <= FKEY1 + 11)
    {
      if (shiftstate & shAnyAlt)
        c = ksAltF11 + ch - (FKEY1 + 10);
      else if (shiftstate & shCtrl)
        c = ksCtrlF11 + ch - (FKEY1 + 10);
      else if (shiftstate & shShift)
        c = ksShF11 + ch - (FKEY1 + 10);
      else
        c = ksF11 + ch - (FKEY1 + 10);
    }
  else if (ch >= FKEYSH1 && ch <= FKEYSH1 + 9)
    c = ksShF1 + ch - FKEYSH1;
  else if (ch >= FKEYCTRL1 && ch <= FKEYCTRL1 + 9)
    c = ksCtrlF1 + ch - FKEYCTRL1;
  else if (ch >= FKEYALT1 && ch <= FKEYALT1 + 9)
    c = ksAltF1 + ch - FKEYALT1;
  else
    c = find_key (FKeyTable, ch);
  if ((shiftstate & shShift) && (shiftstate & shCtrl) && (cs = find_key (ShiftCtrlFKeyTable, c)))
    c = cs;
  else if ((shiftstate & shShift) && (cs = find_key (ShiftFKeyTable, c)))
    c = cs;
  else if ((shiftstate & shCtrl) && (cs = find_key (CtrlFKeyTable, c)))
    c = cs;
  else if ((shiftstate & shAlt) && (cs = find_key (AltFKeyTable, c)))
    c = cs;
  return 0x100 * c;
}

GLOBAL (Char crt_ReadKey (void))
{
  Char tmp;
  int ch;
  if (crt_FKeyBuf)
    {
      tmp = crt_FKeyBuf;
      crt_FKeyBuf = 0;
      return tmp;
    }
  DO_RETURN_ADDRESS (ch = crt_ReadKeyWord ());
  if (ch & 0xff) return ch;
  crt_FKeyBuf= ch / 0x100;
  return 0;
}

GLOBAL (size_t crt_WinSize (void))
{
  DO_CRT_CHECK_WINCHANGED;
  return   (crt_ActivePanel->WindXMax - crt_ActivePanel->WindXMin + 1)
         * (crt_ActivePanel->WindYMax - crt_ActivePanel->WindYMin + 1)
         * sizeof (chtype);
}

GLOBAL (void crt_ReadWin (chtype *buf))
{
  DO_CRT_CHECK_WINCHANGED;
  {
    int xsize = crt_ActivePanel->WindXMax - crt_ActivePanel->WindXMin + 1,
        ysize = crt_ActivePanel->WindYMax - crt_ActivePanel->WindYMin + 1,
        yc, sx, sy;
    chtype temp[xsize + 1];
    getyx (crt_ActivePanel->w, sy, sx);
    for (yc = 0; yc < ysize; yc++)
      {
        mvwinchnstr (crt_ActivePanel->w, yc, 0, temp, xsize);
        memcpy (buf + xsize * yc, temp, xsize * sizeof (chtype));  /* don't copy the 0 terminator! */
      }
    wmove (crt_ActivePanel->w, sy, sx);
  }
}

GLOBAL (void crt_WriteWin (chtype *buf))
{
  DO_CRT_CHECK_WINCHANGED;
  {
    int xsize = crt_ActivePanel->WindXMax - crt_ActivePanel->WindXMin + 1,
        ysize = crt_ActivePanel->WindYMax - crt_ActivePanel->WindYMin + 1,
        yc, sx, sy;
    getyx (crt_ActivePanel->w, sy, sx);
    for (yc = 0; yc < ysize; yc++)
      mvwaddchnstr (crt_ActivePanel->w, yc, 0, buf + xsize * yc, xsize);
    wmove (crt_ActivePanel->w, sy, sx);
    crt_NeedRefresh ();
  }
}

GLOBAL (void crt_ClrScr (void))
{
  crt_SetAttr ();
  werase (crt_ActivePanel->w);
  wmove (crt_ActivePanel->w, 0, 0);
  crt_Cursor.x = crt_Cursor.y = 0;
  crt_NeedRefresh ();
}

GLOBAL (void crt_ClrEOL (void))
{
  crt_SetAttr ();
  wclrtoeol (crt_ActivePanel->w);
  crt_NeedRefresh ();
}

GLOBAL (void crt_InsLine (void))
{
  crt_SetAttr ();
  winsertln (crt_ActivePanel->w);
  (void) idlok (crt_ActivePanel->w, TRUE);
  crt_NeedRefresh ();
}

GLOBAL (void crt_DelLine (void))
{
  crt_SetAttr ();
  wdeleteln (crt_ActivePanel->w);
  (void) idlok (crt_ActivePanel->w, TRUE);
  crt_NeedRefresh ();
}

GLOBAL (void crt_SetPCCharSet (Boolean PCCharSet))
{
  DO_CRT_CHECK_WINCHANGED;
  crt_ActivePanel->PCCharSet = PCCharSet;
}

GLOBAL (Boolean crt_GetPCCharSet (void))
{
  DO_CRT_CHECK_WINCHANGED;
  return crt_ActivePanel->PCCharSet;
}

GLOBAL (void crt_SetControlChars (Boolean UseControlChars))
{
  DO_CRT_CHECK_WINCHANGED;
  crt_ActivePanel->UseControlChars = UseControlChars;
}

GLOBAL (Boolean crt_GetControlChars (void))
{
  DO_CRT_CHECK_WINCHANGED;
  return crt_ActivePanel->UseControlChars;
}

GLOBAL (size_t crt_Read (void *PrivateData UNUSED, Char *buffer, size_t size))
{
  int res;
  size_t n;
  Char *p;
  crt_SetAttr ();
  if (!crt_LineBufCount)
    {
      crt_NoDelay (FALSE);
      crt_RawOut (FALSE);
      echo ();
      if (crt_UpdateLevel >= UpdateWaitInput) crt_Update ();
      do
        {
          errno = 0;
          res = wgetnstr (crt_ActivePanel->w, (char *)crt_LineBuf, MAXLENGTH - 1);
        }
      while
        #ifdef EINTR
        (res == ERR && errno == EINTR);
        #else
        (0);
        #endif
      if (res == ERR)
        crt_LineBufCount = 0;
      else
        {
          if (crt_CheckEOF)
            {
              do
                {
                  p = (Char *)strchr ((char *)crt_LineBuf, 26);
                  if (p) *p = 0;
                }
              while (p);
            }
          crt_LineBufCount = strlen ((char *)crt_LineBuf);
          crt_LineBuf[crt_LineBufCount++] = '\n';
        }
      crt_LineBufPos = crt_LineBuf;
      noecho ();
      crt_RawOut (TRUE);
    }
  n = (crt_LineBufCount < size) ? crt_LineBufCount : size;
  memcpy (buffer, crt_LineBufPos, n);
  crt_LineBufPos += n;
  crt_LineBufCount -= n;
  return n;
}

GLOBAL (void crt_Flash (void))
{
  DO_CRT_CHECK_WINCHANGED;
  flash ();
}

GLOBAL (void crt_Beep (void))
{
  DO_CRT_CHECK_WINCHANGED;
  if (crt_VisualBell)
    crt_Flash ();
  else
    {
      beep ();
      crt_Delay (100);
    }
}

static chtype chtransform (Char ch, TTextAttr attr, Boolean PCCharSet)
{
  Boolean pccs = PCCharSet || (ch < ' ');
  if (ch == 0
  #ifdef XCURSES
    || (crt_ColorFlag && (attr & 7) == ((attr >> 4) & 7))
  #endif
    || (attr & ~(crt_ColorFlag ? 0x80 : 0x88)) == 0)
    return ' ';
  #if !defined (USE_PDCURSES) || defined (XCURSES)
  if ((!crt_LinuxConsole && pccs)
      || ch == chBell || ch == chBkSp || ch == chTab || ch == chLF || ch == chFF
      || ch == chCR || ch == chEsc || ch == 14 || ch == 15 || ch == 155)
    {
      if (ch < 32) return chars_0_31[ch];
      if (ch >= 128)
        {
          chtype c = chars_128_255[ch - 128];
          #ifdef XCURSES
          /* ACS_BLOCK is not supported in all charsets, but we can emulate it */
          if (c == ACS_BLOCK)
            c = ' ' | crt_Attr2CursAttr ((attr >> 4) | ((attr & 15) << 4));
          #endif
          return c;
        }
    }
  #endif
  if (!pccs && !_p_IsPrintable (ch)) return ' ';
  return (crt_LinuxConsole && pccs && (ch < 32 || ch > 126)) ? ch | A_ALTCHARSET : ch;
}

GLOBAL (void crt_ReadChar (int x, int y, Char *ch, TTextAttr *attr))
{
  int sx, sy, cc;
  chtype c;
  crt_SetAttr ();
  getyx (crt_ActivePanel->w, sy, sx);
  c = mvwinch (crt_ActivePanel->w, y - 1, x - 1);
  *attr = cursattr2attr (c);
  c &= A_CHARTEXT;
  for (cc = 0x20; cc < 0x120 && (chtransform (cc % 0x100, 7, crt_ActivePanel->PCCharSet) & A_CHARTEXT) != c; cc++);
  *ch = cc % 0x100;
  wmove (crt_ActivePanel->w, sy, sx);
}

GLOBAL (void crt_FillWin (Char ch, TTextAttr attr))
{
  DO_CRT_CHECK_WINCHANGED;
  wbkgdset (crt_ActivePanel->w, crt_Attr2CursAttr (attr) | chtransform (ch, attr, crt_ActivePanel->PCCharSet));
  werase (crt_ActivePanel->w);
  crt_SetAttr ();
  crt_NeedRefresh ();
}

GLOBAL (size_t crt_Write (void *PrivateData UNUSED, const Char *buffer, size_t size))
{
  size_t i;
  Char ch;
  crt_SetAttr ();
  for (i = 0; i < size; i++)
    {
      ch = buffer[i];
      if (crt_ActivePanel->UseControlChars)
        {
          if (ch == chBell)
            {
              crt_Beep ();
              continue;
            }
          else if (ch == chBkSp)
            {
              int x, y;
              getyx (crt_ActivePanel->w, y, x);
              if (x > 0)
                wmove (crt_ActivePanel->w, y, x - 1);
              continue;
            }
          else if (ch == chLF)
            {
              int x, y;
              getyx (crt_ActivePanel->w, y, x);
              if (y + crt_ActivePanel->WindYMin >= crt_ActivePanel->WindYMax)
                {
                  if (crt_ActivePanel->ScrollState) wscrl (crt_ActivePanel->w, 1);
                  wmove (crt_ActivePanel->w, y, 0);
                }
              else
                wmove (crt_ActivePanel->w, y + 1, 0);
              continue;
            }
          else if (ch == chCR)
            {
              int x, y;
              getyx (crt_ActivePanel->w, y, x);
              wmove (crt_ActivePanel->w, y, 0);
              continue;
            }
        }
      waddch (crt_ActivePanel->w, chtransform (ch, crt_TextAttr, crt_ActivePanel->PCCharSet));
    }
  crt_UpdateCursorPos ();
  crt_NeedRefresh ();
  return size;
}

GLOBAL (void crt_WriteCharAttrAt (int x, int y, int Count, TCharAttr *CharAttr))
{
  crt_SetAttr ();
  {
    int m = crt_ActivePanel->WindXMax - crt_ActivePanel->WindXMin + 1 - x + 1;
    if (Count > m) Count = m;
    if (Count > 0)
      {
        chtype buf[Count];
        int cattr = 0, LastAttr = -1, sx, sy, i;
        TTextAttr Attr;
        for (i = 0; i < Count; i++)
          {
            Attr = CharAttr[i].Attr;
            if (Attr != LastAttr)
              {
                cattr = crt_Attr2CursAttr (Attr);
                LastAttr = Attr;
              }
            buf[i] = chtransform (CharAttr[i].Ch, Attr, CharAttr[i].PCCharSet) | cattr;
          }
        getyx (crt_ActivePanel->w, sy, sx);
        wmove (crt_ActivePanel->w, y - 1, x - 1);
        crt_SetScroll (FALSE);
        waddchnstr (crt_ActivePanel->w, buf, Count);
        crt_SetScroll (crt_ActivePanel->ScrollState);
        wmove (crt_ActivePanel->w, sy, sx);
        crt_NeedRefresh ();
      }
  }
}
