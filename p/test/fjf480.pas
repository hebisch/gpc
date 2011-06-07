{ The test is problematic. See the comment in fjf480.run }

program fjf480;
var a,c,d,e,f:text;x:char;
begin
  assign(a,'');
  reset(a);
  readln(a,x);
  close(a);
  assign(d,'');
  rewrite(d);
  write(d,x);
  close(d);
  extend(f,'test.dat');
  writeln(f,'K');
  close(f);
  assign(c,'');
  reset(c);
  read(c,x);
  close(c);
  rewrite(d);
  write(d,x);
  close(d);
  assign(e,'');
  rewrite(e);
  writeln(e);
  close(e);
end.
