program fjf887o;

var
  a: array [1 .. 10] of Integer;
  b: packed array [1 .. 5] of Integer;

begin
  Unpack (b, a, 0)  { WRONG }
end.
