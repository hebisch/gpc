program fjf569w;

type
  t = set of 0 .. 255;

procedure Test (protected s: t);
begin
  if s = [55, 77] then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  Test ([77] + [55])
end.
