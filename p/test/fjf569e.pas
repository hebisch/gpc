program fjf569e;

type
  t = set of 0 .. 255;

procedure Test (protected s: t);
var
  s2: type of s;
begin
  s2 := s + [3];
  if s2 = [3, 5, 7] then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  Test ([5, 7]);
end.
