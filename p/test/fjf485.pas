program fjf485;

var
  f:file of char;
  a,b,c,d:char;

begin
  rewrite(f);
  write(f,'q','w','e','r','t');
  reset(f);
  read(f,a,b,c,d);
  writeln(a,b,c,d);
  rewrite(f);
  f^:='x';
  put(f);
  f^:='y';
  put(f);
  reset(f);
  read(f,a,b);
  writeln(a,b);
  reset(f);
  write(f^);
  get(f);
  writeln(f^);
end.
