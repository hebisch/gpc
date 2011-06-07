program fjf488xh;

var
  a : integer = 42;
  f : text;

begin
  writeln ('failed');
  halt;
  assign (f, a)  { WRONG }
end.
