/* Note `--unsigned-bitfields' in fjf203.pas */

extern int puts (char *s);

void ok ()
{
  struct { int i: 2; } x;
  x.i = -2;
  if (x.i > 0) puts ("OK"); else puts ("failed");
}
