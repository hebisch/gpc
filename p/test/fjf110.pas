program fjf110;
var a:file of char;b,c:char;
begin
  rewrite(a,'tmp.dat');
  write(a,'x','O','K','x');
  seek(a,1);
  read(a,b,c);
  writeln(b,c);
  close(a)
end.
