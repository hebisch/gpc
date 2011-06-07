/*GPC demo code. C program that includes the Pascal program
  gpc_c_pas.pas.

  Copyright (C) 2000-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation, version 2.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING. If not, write to
  the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA.

  As a special exception, if you incorporate even large parts of the
  code of this demo program into another program with substantially
  different functionality, this does not cause the other program to
  be covered by the GNU General Public License. This exception does
  not however invalidate any other reasons why it might be covered
  by the GNU General Public License. */

#include <stdio.h>
#include <gpc-in-c.h>

/* External declarations we use from the Pascal code */

extern int pascal_program_variable;
extern void pascal_program_routine ();

extern int pascal_unit_variable;
extern void pascal_unit_routine ();

/* C code */

int c_variable = 42;

void c_routine ()
{
  printf ("C routine called from Pascal code.\n");
  printf ("c_variable is now %i.\n", c_variable);
  fflush (stdout);
}

int main (int argc, char **argv, char **envp)
{
  printf ("Starting in the C `main'.\nInitializing the Pascal RTS.\n");
  fflush (stdout); /* So the text really appears now. */
  _p_initialize (argc, argv, envp, 0);

  printf ("Calling the Pascal initializers.\n");
  fflush (stdout);
  init_pascal_main_program ();

  printf ("Back in C `main'.\n");
  printf ("Incrementing pascal_unit_variable.\n");
  pascal_unit_variable++;

  printf ("Calling pascal_unit_routine.\n");
  fflush (stdout);
  pascal_unit_routine ();

  printf ("Back in C `main'.\n");
  printf ("c_variable is %i.\n", c_variable);
  printf ("Setting pascal_program_variable to 12345.\n");
  pascal_program_variable = 12345;

  printf ("Calling pascal_program_routine.\n");
  fflush (stdout);
  pascal_program_routine ();

  printf ("Back in C `main'.\n");
  printf ("Calling the Pascal finalizer.\n");
  fflush (stdout);
  _p_finalize ();

  printf ("Done.\n");
  fflush (stdout);

  return 0;
}
