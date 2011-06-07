program fjf900a;

type
  t (n: Integer) = array [2 .. n] of Integer;

var
  v: ^t;

begin
  New (v, 1)  { WRONG }
end.
