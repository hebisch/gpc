program fjf589e;

type
  x (n: Cardinal) = array [1 .. n] of Integer;
  y = x (42);

begin
  if (Low (y) = 1) and (High (y) = 42) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
