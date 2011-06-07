program fjf504;

type
  t = 1 .. 10;
  x (y : t) = array [1 .. y] of Integer;

var
  a : x (5);

begin
  if a.y = 5 then WriteLn ('OK') else WriteLn ('failed')
end.
