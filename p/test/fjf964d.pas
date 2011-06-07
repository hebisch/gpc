program fjf964d;

var
  a: array [1 .. 2] of Integer = [1: 2; 2: 3 otherwise 4];

begin
  if (a[1] = 2) and (a[2] = 3) then WriteLn ('OK') else WriteLn ('failed')
end.
