program fjf581;

type
  T = packed array [0 .. 14] of 0 .. 1;

var
  A: T value (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);  { WARN }

begin
  WriteLn ('failed')
end.
