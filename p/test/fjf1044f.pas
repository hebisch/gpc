program fjf1044f;

type
  t (n: Integer) = array [1 .. n] of Integer;

var
  a: array [1 .. 10] of t (42);
  b: packed array [21 .. 30] of t (43);

begin
  Pack (a, 1, b)  { WRONG }
end.
