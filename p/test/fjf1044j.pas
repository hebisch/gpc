program fjf1044j;

type
  t (n: Integer) = array [1 .. n] of Integer;
  u (a, b, c: Integer) = array [a .. b] of Integer;

var
  a: t (2);
  d: u (1, 2, 3);

begin
  a := d  { WRONG }
end.
