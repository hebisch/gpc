program fjf1051b (Output);

type
  t (n: Integer) = Integer;
  t10 = t (10);

procedure p (var s: t10);
begin
  if s = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

var
  s: t10;

begin
  s := 42;
  p (s)
end.
