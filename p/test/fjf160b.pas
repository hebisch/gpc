program fjf160b;

var
  a:file of char;
  b,c:char;

begin
  rewrite(a,'test.dat');
  write(a,'X','Y');
  close(a);
  reset(a,'test.dat');
  if eof(a) then begin writeln ('failed'); halt end;
  write(a,'O','K');
  close(a);
  reset(a,'test.dat');
  read(a,b,c);
  close(a);
  writeln(b,c);
end.
