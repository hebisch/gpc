#include <stdio.h>
#include <stdlib.h>
extern void do_def(const char * x);
extern void do_val(const char * x, int y);
extern void tstdefs(void);

void
do_def(const char * x)
{
  printf("%s\n", x);
}
void
do_val(const char * x, int y)
{
  printf("%s=%d\n", x, y);
}

int
main (void)
{
  tstdefs ();
  return EXIT_SUCCESS;
}
