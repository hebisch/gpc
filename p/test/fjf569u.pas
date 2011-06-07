program fjf569u;

type
  t = set of 0 .. 255;

procedure Test (protected s: t);
begin
  if s = [77, 55] then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  Test ([55, 77])
end.
