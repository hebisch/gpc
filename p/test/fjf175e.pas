program fjf175e;

var
  a : array [1 .. 2] of record b, c: Integer end = ((), (3, 4));

begin
  if (a[2].b = 3) and (a[2].c = 4) then WriteLn ('OK') else WriteLn ('failed')
end.
