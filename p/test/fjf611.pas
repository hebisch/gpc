program fjf611;

type
  t (Count: Cardinal) = array [1 .. Count + 1] of Integer;

var
  v: t (2) = (1, 2, 3, 4);  { WRONG }

begin
  WriteLn ('failed')
end.
