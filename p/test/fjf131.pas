program fjf131;
var c:text;x:char;
begin
  rewrite(c);
  write(c,'O','K');
  reset(c);
  read(c,x);write(x);
  read(c,x);writeln(x);
  close(c)
end.
