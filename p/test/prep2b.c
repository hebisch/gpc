/* Separate file, we do not want standard headers to pollute
   macro namespace */
extern void do_def(const char * x);
extern void do_val(const char * x, int y);
void
tstdefs(void)
{
  #include "prep2p.inc"
}
