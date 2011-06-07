/*This file implements some system-specific functions, as described
  in crtc.c, for DJGPP (using PDCurses).

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

#include <pc.h>
#include <go32.h>
#include <dpmi.h>

extern void _p_SleepMicroSeconds (int MicroSeconds);
#undef napms
#define napms(ms) _p_SleepMicroSeconds (10000 * (ms))

/* We could also use the PDCurses version (by removing the following
   define and function), but this function will distinguish between
   left and right modifiers better. */
#define HAVE_CRT_GETSHIFTSTATE
GLOBAL (int crt_GetShiftState (void))
{
  int state = crt_VirtualShiftState;
  unsigned short bios_state;
  /* read a word from BIOS memory at linear address 0x417 (i.e., 0x40:0x17) */
  _dosmemgetw (0x417, 1, &bios_state);
  if (bios_state & 2) state |= shLeftShift;
  if (bios_state & 1) state |= shRightShift;
  if (bios_state & 4) state |= (bios_state & 0x100) ? shLeftCtrl : shRightCtrl;
  if (bios_state & 8) state |= (bios_state & 0x200) ? shLeftAlt  : shRightAlt;
  if (bios_state & 0x1000) state |= shExtra;
  return state;
}

#define HAVE_CRT_SOUND
GLOBAL (void crt_Sound (unsigned Hz))
{
  sound (Hz);
}

GLOBAL (void crt_NoSound (void))
{
  nosound ();
}

static void VideoInterrupt (int a, int b, int c, int d, int *ra, int *rb, int *rc, int *rd)
{
  __dpmi_regs Regs;
  memset (&Regs, 0, sizeof (Regs));
  Regs.x.ax = a;
  Regs.x.bx = b;
  Regs.x.cx = c;
  Regs.x.dx = d;
  __dpmi_int (0x10, &Regs);
  if (ra) *ra = Regs.x.ax;
  if (rb) *rb = Regs.x.bx;
  if (rc) *rc = Regs.x.cx;
  if (rd) *rd = Regs.x.dx;
}

typedef struct
{
  int Mode, Rows, Columns, Pos, Shape;
} TScrData;

static void GetMode (TScrData *ScrData)
{
  VideoInterrupt (0xf00, 0, 0, 0, &ScrData->Mode, NULL, NULL, NULL);
  VideoInterrupt (0x1130, 0, 0, 0, NULL, NULL, NULL, &ScrData->Rows);
  ScrData->Rows = (ScrData->Rows & 0xff) + 1;
  if (ScrData->Rows <= 1) ScrData->Rows = 25;
  ScrData->Columns = ScrData->Mode / 0x100;
  ScrData->Mode = ScrData->Mode % 0x100;
  VideoInterrupt (0x300, 0, 0, 0, NULL, NULL, &ScrData->Shape, &ScrData->Pos);
}

static void SetMode (TScrData *ScrData, TScrData *Other)
{
  if (ScrData->Mode != Other->Mode || ScrData->Rows != Other->Rows || ScrData->Columns != Other->Columns)
    {
      VideoInterrupt (0x1202, 0x30, 0, 0, NULL, NULL, NULL, NULL);
      VideoInterrupt (ScrData->Mode, 0, 0, 0, NULL, NULL, NULL, NULL);
      if (ScrData->Rows > 25)
        {
          int TmpRows;
          VideoInterrupt (0x1112, 0, 0, 0, NULL, NULL, NULL, NULL);
          VideoInterrupt (0x1130, 0, 0, 0, NULL, NULL, NULL, &TmpRows);
          if (TmpRows == 42) VideoInterrupt (0x1200, 0x20, 0, 0, NULL, NULL, NULL, NULL);
        }
    }
  VideoInterrupt (0x200, 0, 0, ScrData->Pos, NULL, NULL, NULL, NULL);
  VideoInterrupt (0x100, 0, ScrData->Shape, 0, NULL, NULL, NULL, NULL);
}

#define HAVE_CRT_SAVE_RESTORE_SCREEN
static int crt_SaveRestoreScreen (Boolean Restore)
{
  static int OrigModeSet = 0, ProgModeSet = 0;
  static TScrData Orig, Prog;
  static void *Buf = NULL;
  if (!Restore)
    {
      GetMode (&Orig);
      OrigModeSet = 1;
      if (Buf) free (Buf);
      if ((Buf = malloc (2 * Orig.Columns * Orig.Rows))) ScreenRetrieve (Buf);
      if (ProgModeSet) SetMode (&Prog, &Orig);
    }
  else
    {
      GetMode (&Prog);
      ProgModeSet = 1;
      if (OrigModeSet) SetMode (&Orig, &Prog);
      if (Buf) ScreenUpdate (Buf);
    }
  return Buf != NULL;
}
