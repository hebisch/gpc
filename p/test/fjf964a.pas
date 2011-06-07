program fjf964a;

var
  a: array [1 .. 2, 1 .. 2] of Integer = ((3, 4), (5, 6));
  b: Integer = ((2));

begin
  if (a[(1), (2)] = 4) and (b = 2) then WriteLn ('OK') else WriteLn ('failed')
end.
