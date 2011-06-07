program fjf887m;

var
  a: packed array [1 .. 10] of Integer;

begin
  FillChar (a[0 .. 4], 1, 0)  { WRONG }
end.
