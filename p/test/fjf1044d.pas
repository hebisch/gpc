program fjf1044d;

type
  t (n: Integer) = array [1 .. n] of Integer;
  u (a, b, c: Integer) = array [a .. b] of Integer;

var
  a: array [1 .. 10] of t (2);
  d: packed array [21 .. 30] of u (1, 2, 3);

begin
  Pack (a, 1, d)  { WRONG }
end.
