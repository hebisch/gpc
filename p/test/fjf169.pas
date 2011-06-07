program fjf169;
var
  f:text;
  s:string(2);
begin
  rewrite(f,'test.dat');
  writeln(f,'OK');
  close(f);
  reset(f);
  readln(f,s);
  close(f);
  writeln(s)
end.
