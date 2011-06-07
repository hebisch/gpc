program fjf488xp;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln (Pos (a, ''))  { WRONG }
end.
