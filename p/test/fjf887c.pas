program fjf887c;

var
  a: array [1 .. 10] of Integer;
  b: packed array [1 .. 5] of Integer;

begin
  Pack (a, 7, b)  { WRONG }
end.
