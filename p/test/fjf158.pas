program fjf158;

var
  a:file of char;
  b,c:char;

begin
  rewrite(a);
  write(a,'X','Y');
  reset(a);
  write(a,'O','K');
  reset(a);
  read(a,b,c);
  close(a);
  writeln(b,c);
end.
