program fjf157;

var
  a:file of char;
  b,c:char;

begin
  rewrite(a,'test.dat');
  write(a,'X','Y');
  close(a);
  reset(a,'test.dat');
  write(a,'O','K');
  reset(a);
  read(a,b,c);
  close(a);
  writeln(b,c);
end.
