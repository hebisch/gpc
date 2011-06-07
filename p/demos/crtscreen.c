/*This is not a GPC demo program, but a utility to make the
  CRTSavePreviousScreen feature of the CRT unit work on Linux
  consoles for normal users (for root and other users with access to
  the virtual console memory devices, it works without this
  utility). It's currently only for Linux, but may easily be ported
  to other systems that have something similar to Linux' virtual
  console memory devices, and no "alternate screen" features or
  similar (where those are present (e.g. in xterms, but not on the
  Linux console), this utility isn't needed, either).

  Before installing it, please note that there is some security
  issue: Direct access to the console's contents under Linux is done
  through the virtual console memory devices (/dev/vcsa*, or
  /dev/vcc/a* on newer kernels using devfs), rather than terminal
  operations, since kernel 1.1.92, so the system administrator can
  control access. This program is one way to grant limited access to
  them. It allows to save the screen contents and restore them
  later. As a security measure, to prevent terminal sniffing
  attacks, it refuses both saving and restoring while the invoking
  user has no read/write access to the corresponding terminal. This
  should be reasonably safe, but I can give no guarantee, so you
  might be wary of installing it on a multi-user system where
  security is a concern.

  That said, if you want to install it, you have to give it
  read/write permissions to the virtual console memory devices.
  E.g., create a group `vcs', set the group ownership of these
  devices and the executable of this program to that group, make the
  devices group readable and writable, and give the exectuable the
  setgid privilege. The following commands, executed as root, will
  do that.

  Without devfs:

    gcc -Wall -O3 -o crtscreen crtscreen.c
    groupadd vcs
    chgrp vcs /dev/vcsa* crtscreen
    chmod g=rw /dev/vcsa*
    chmod 2555 crtscreen

  With devfs:

    gcc -Wall -O3 -o crtscreen crtscreen.c
    groupadd vcs
    chmod 2555 /usr/local/bin/crtscreen

    Put the following line into /etc/devfsd.conf:

    REGISTER ^vcc/.*$ PERMISSIONS root.vcs 660

    Afterwards, you may have to restart devfsd.

  It is *not* recommended to make this executable setuid root
  because that would increase the effects of any possible bugs.

  Copyright (C) 1999-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation, version 2.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING. If not, write to
  the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA. */

#ifndef linux
#error This program was only written for Linux.
#endif

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

/* Non-devfs */
#define DEV_TTY "/dev/tty"
#define DEV_VCSA "/dev/vcsa"

/* devfs */
#define DEV_VC "/dev/vc/"
#define DEV_VCCA "/dev/vcc/a"

static int VcsaFile, BufSize = 0x1000, Count = 0;
static char *Buffer = 0;
static const char *tty;

static int reset_file ()
{
  /* Check if access to the terminal is currently permitted, using the
     real user ID, in order to prevent terminal sniffing attacks. */
  if (access (tty, R_OK | W_OK))
    return 0;
  lseek (VcsaFile, 0, SEEK_SET);
  return 1;
}

static int crt_SaveRestoreScreenInternal (int Restore)
{
  ssize_t r, c = 0;
  if (!reset_file ())
    return 0;
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

static void winch_handler (int sig)
{
  char newsize[2], *NewBuffer;
  int ox, oy, x, y, s, mx, i;
  signal (sig, winch_handler);
  if (!Buffer || !reset_file () || read (VcsaFile, newsize, sizeof (newsize)) != sizeof (newsize))
    return;
  y = newsize[0];
  x = newsize[1];
  oy = Buffer[0];
  ox = Buffer[1];
  if (!(NewBuffer = malloc ((s = 4 + 2 * x * y))))
    return;
  memmove (NewBuffer, newsize, 2);
  memmove (NewBuffer + 2, Buffer + 2, 2);
  for (i = 4; i < s; i++)
    NewBuffer[i] = (i & 1) ? 7 : 32;
  mx = x < ox ? x : ox;
  for (i = 0; i < y && i < oy; i++)
    memmove (NewBuffer + 4 + 2 * x * i, Buffer + 4 + 2 * ox * i, 2 * mx);
  free (Buffer);
  Buffer = NewBuffer;
  BufSize = Count = s;
}

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

int main ()
{
  int r;
  char Mode;
  const char *t;
  signal (SIGWINCH, winch_handler);
  if (!getenv ("DISPLAY")
      && isatty (2)
      && (tty = ttyname (2))
      && !access (tty, R_OK | W_OK)
      && ((t = ttynum (tty, DEV_TTY))
          || (t = ttynum (tty, DEV_VC)))
      && ((VcsaFile = open2 (DEV_VCSA, t)) >= 0
          || (VcsaFile = open2 (DEV_VCCA, t)) >= 0))
    do
      {
        r = read (0, &Mode, 1);
        if (r > 0 && (Mode == 'S' || Mode == 'R'))
          {
            if (!crt_SaveRestoreScreenInternal (Mode == 'R'))
              write (1, "E", 1);
            else if (write (1, "O", 1) < 0 && errno != EINTR)
              break;
          }
      }
    while (r > 0 || (r < 0 && errno == EINTR));
  write (1, "F", 1);
  return 1;
}
