program fjf1048 (Output);

type
  e = (f, g, h, i, j, k);

var
  a: array [f .. g] of Integer;
  b: packed array [h .. k] of Integer;

begin
  Pack (a, f, b)  { WRONG }
end.
