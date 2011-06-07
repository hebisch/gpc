program fjf887e;

type
  r = 1 .. 10;
  t (n: r) = Integer;

var
  a: ^t;

begin
  New (a, 12)  { WRONG }
end.
