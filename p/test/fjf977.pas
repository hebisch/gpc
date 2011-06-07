program fjf977;

type
  t = set of 1 .. 10;

var
  a, b: t;

begin
  (a + b) := []  { WRONG }
end.
