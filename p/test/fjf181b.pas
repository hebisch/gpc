program fjf181b;

type
  t = String (42);

begin
  if (Low (t) = 1) and (High (t) = 42) then WriteLn ('OK') else WriteLn ('failed')
end.
