{$undef out}{$define out WriteLn(foo}
  tst(out);
{$if not defined (Classic) and not defined (Borland)}
{$undef out}{$define out WriteLn(foo,buf);writestr(buf}
  tst(out);
  out,emptystring);
{$endif}
{$if not defined (Standard) and not defined (Borland)}
{$undef out}{$define out
  bc:=b2h;
  while (bc>=b2l) and (buf2[bc]=' ') do dec(bc);
  for bz:=b2l to bc do write(foo,buf2[bz]);
  WriteLn(foo);
  writestr(buf2}
  tst(out);
  out,emptystring);
{$endif}
  out,emptystring);
