program fjf569v;

type
  t = set of 0 .. 255;

procedure Test (protected s: t);
begin
  if s = [0, 255] then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  Test ([0] + [255])
end.
