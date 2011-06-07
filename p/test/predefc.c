#include <stdio.h>

void OK (void)
{
#ifdef __i386
#ifdef __i386__
  puts ("OK");
#else
  puts ("failed");
#endif
#else
  puts ("OK");  /* no test here */
#endif
}
