program fjf175c;

var
  a : array [1 .. 2] of record b, c: Integer end = ((1, 2), ());

begin
  if (a[1].b = 1) and (a[1].c = 2) then WriteLn ('OK') else WriteLn ('failed')
end.
