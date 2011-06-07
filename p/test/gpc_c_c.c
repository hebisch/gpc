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
