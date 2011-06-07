/*Support routines for the Trap unit

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

#include <setjmp.h>

#define GLOBAL(decl) decl; decl

/* jmp_buf may be an array which doesn't allow assignments in :-C,
   so wrap it up in a struct. */
typedef struct
{
  jmp_buf buf;
} jmp_buf_struct;

jmp_buf_struct state;

GLOBAL (void dosetjmp (void (*p) (unsigned char)))
{
  volatile jmp_buf_struct prev = state;  /* setjmp requires `volatile' */
  if (setjmp (state.buf) != 0)  /* Don't use setjmp in an argument list or ?: */
    (*p) (1);
  else
    (*p) (0);
  state = prev;
}

GLOBAL (void dolongjmp (void))
{
  longjmp (state.buf, 1);
}
