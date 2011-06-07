/*This file implements some system-specific functions, as described
  in crtc.c, for a Linux/IA32 system. Actually, they're probably not
  IA32-specific, but I've had no chance to test them on another
  processor yet.

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

#include <fcntl.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <asm/ioctls.h>
#include <linux/kd.h>

#define HAVE_CRT_GETSHIFTSTATE
GLOBAL (int crt_GetShiftState (void))
{
  int state = crt_VirtualShiftState;
  char arg = 6;
  if (ioctl (crt_Get_Input_FD (), TIOCLINUX, &arg) == 0)
    {
      if (arg & (1 | 16)) state |= shLeftShift;
      if (arg & (1 | 32)) state |= shRightShift;
      if (arg & 4)        state |= shCtrl;
      if (arg & 8)        state |= shLeftAlt;
      if (arg & 2)        state |= shRightAlt;
      if (arg & 64)       state |= shExtra;
    }
  return state;
}

#define HAVE_CRT_SOUND
GLOBAL (void crt_Sound (unsigned Hz))
{
  ioctl (crt_Get_Output_FD (), KIOCSOUND, (Hz <= 18) ? 0 : 1193181 / Hz);
}

GLOBAL (void crt_NoSound (void))
{
  ioctl (crt_Get_Output_FD (), KIOCSOUND, 0);
}

/* Non-devfs */
#define DEV_TTY "/dev/tty"
#define DEV_VCSA "/dev/vcsa"

/* devfs */
#define DEV_VC "/dev/vc/"
#define DEV_VCCA "/dev/vcc/a"

static const char *ttynum (const char *t, const char *prefix)
{
  int l;
  const char *c;
  if (strncmp (t, prefix, (l = strlen (prefix))) || !*(t += l)) return NULL;
  for (c = t; *c >= '0' && *c <= '9'; c++);
  return (!*c) ? t : NULL;
}

static int open2 (const char *prefix, const char *suffix)
{
  char Buf[strlen (prefix) + strlen (suffix) + 1];
  if (sprintf (Buf, "%s%s", prefix, suffix) <= 0) return -1;
  return open (Buf, O_RDWR);
}

#define HAVE_CRT_SAVE_RESTORE_SCREEN
/* Return value:
   -1: not a local console
    0: no access to vcsa device
    1: ok */
static int crt_SaveRestoreScreenInternal (Boolean Restore)
{
  static int NoConsole = 0, VcsaFile = 0, BufSize = 0x1000, Count = 0;
  static char *Buffer = 0;
  ssize_t r, c = 0;
  if (NoConsole) return -1;
  if (!VcsaFile)
    {
      const char *tty, *t;
      tty = ttyname (crt_Get_Output_FD ());
      if (!tty || !strcmp (tty, "/dev/tty"))
        tty = ttyname (2);
      if (!tty || getenv ("DISPLAY") || !((t = ttynum (tty, DEV_TTY)) || (t = ttynum (tty, DEV_VC))))
        {
          NoConsole = 1;
          return -1;
        }
      if ((VcsaFile = open2 (DEV_VCSA, t)) < 0)
        VcsaFile = open2 (DEV_VCCA, t);
    }
  if (VcsaFile < 0) return 0;
  lseek (VcsaFile, 0, SEEK_SET);
  if (!Restore)
    do
      if ((!Buffer || c >= BufSize) && (!(Buffer = realloc (Buffer, BufSize *= 2))))
        return 0;
      else if ((r = read (VcsaFile, Buffer + c, BufSize - c)) >= 0)
        Count = c += r;
      else if (errno != EINTR)
        return 0;
    while (r);
  else if (!Count)
    return 0;
  else
    do
      if ((r = write (VcsaFile, Buffer + c, Count - c)) >= 0)
        c += r;
      else if (errno != EINTR)
        return 0;
    while (r && c < Count);
  return 1;
}

static int crt_SaveRestoreScreen (Boolean Restore)
{
  static int po[2], pi[2];
  static pid_t pid = 0;
  struct sigaction action, old_action;
  char Res = ' ';
  int internal = crt_SaveRestoreScreenInternal (Restore), a;
  if (internal > 0)
    return 1;
  if (internal < 0)
    /* Call crt_DefaultSaveRestoreScreen, e.g. for xterms under Linux */
    return crt_DefaultSaveRestoreScreen (Restore);
  if (!pid)
    {
      if (pipe (po) < 0 || pipe (pi) < 0 || (pid = fork ()) < 0)
        pid = -1;
      else if (!pid)
        {
          signal (SIGINT, SIG_IGN);
          signal (SIGQUIT, SIG_IGN);
          signal (SIGTSTP, SIG_IGN);
          dup2  (po[1], 1);
          close (po[0]);
          close (po[1]);
          dup2  (pi[0], 0);
          close (pi[0]);
          close (pi[1]);
          execlp ("crtscreen", "crtscreen", NULL);
          _exit (127);
        }
      else
        {
          close (po[1]);
          close (pi[0]);
        }
    }
  if (pid < 0)
    return 0;
  /* Ignore SIGPIPE which might occur when the child terminates for
     lack of permissions before we can do the write(). Blocking is
     not enough, as the signal would then be delivered after
     unblocking. */
  action.sa_handler = SIG_IGN;
  sigemptyset (&action.sa_mask);
  action.sa_flags = 0;
  a = sigaction (SIGPIPE, &action, &old_action);
  if (write (pi[1], Restore ? "R" : "S", 1) < 0 || read (po[0], &Res, 1) < 1 || Res == 'F')
    {
      close (pi[1]);
      close (po[0]);
      waitpid (pid, NULL, WNOHANG);
      pid = -1;
    }
  if (!a) sigaction (SIGPIPE, &old_action, NULL);
  return Res == 'O';
}
