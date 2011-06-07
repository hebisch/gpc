program fjf488xd;

var
  a : integer = 42;
  f : text;

begin
  writeln ('failed');
  halt;
  rename (f, a)  { WRONG }
end.
