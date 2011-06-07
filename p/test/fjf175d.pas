program fjf175d;

var
  a : array [1 .. 2] of record b, c: Integer end = ((1, 2), (3, 4));

begin
  if (a[1].b = 1) and (a[1].c = 2) and (a[2].b = 3) and (a[2].c = 4) then WriteLn ('OK') else WriteLn ('failed')
end.
