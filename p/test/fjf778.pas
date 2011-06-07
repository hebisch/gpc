program fjf778;

var
  a: array [1 .. 1000] of Integer;
  b: packed array [1 .. 1000] of Byte;

begin
  Pack (a, 1, b)  { WRONG }
end.
