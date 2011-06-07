program fjf589f;

type
  q (n: Cardinal) = String (n);
  y = q (42);

begin
  if (Low (y) = 1) and (High (y) = 42) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
