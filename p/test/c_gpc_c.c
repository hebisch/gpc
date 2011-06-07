#include <stdio.h>

/* External declarations we use from the Pascal code */

extern int pascal_program_variable;
extern void pascal_program_routine ();

/* C code */

int c_variable = 42;

void c_routine ()
{
  printf ("C routine called from Pascal code.\n");
  printf ("c_variable is %i.\n", c_variable);
  fflush (stdout); /* So the text really appears now. */

  printf ("Calling pascal_program_routine.\n");
  fflush (stdout);
  pascal_program_routine ();

  printf ("Back in C routine.\n");
  printf ("c_variable is now %i.\n", c_variable);
  printf ("Setting pascal_program_variable to 12345.\n");
  pascal_program_variable = 12345;
  fflush (stdout);
}
