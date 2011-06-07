program fjf159;

var
  a:file of char;
  b,c:char;

begin
  rewrite(a);
  write(a,'X','Y');
  reset(a);
  if eof(a) then begin writeln ('failed'); halt end;
  write(a,'O','K');
  reset(a);
  read(a,b,c);
  close(a);
  writeln(b,c);
end.
