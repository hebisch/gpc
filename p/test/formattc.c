#include <time.h>

#define GLOBAL(decl) decl; decl
GLOBAL (int cstrftime (long long int Time, char *Format, char *Buf, int Size))
{
  time_t seconds = (time_t) Time;
  struct tm *gnu = localtime (&seconds);
  int Res;
  /* see (libc)strftime on how to check for errors */
  Buf[0] = 1;
  Res = strftime (Buf, Size, Format, gnu);
  return Res == 0 && Buf[0] ? -1 : Res;
}
