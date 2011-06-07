program fjf686;

var
  a: array [1 .. 1, 1 .. 1] of Integer = 1 + ((2));  { WRONG }

begin
  WriteLn ('failed ', a[1, 1])
end.
