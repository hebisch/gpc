program fjf887j;

var
  a: array [1 .. 10] of Integer;

begin
  FillChar (a[5 .. 11], 1, 0)  { WRONG }
end.
