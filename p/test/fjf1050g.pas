program fjf1050g (Output);

type
  r = record b: Integer end;
  t (n: Integer) = r value [b: n];

procedure p (a: r);
begin
  if a.b = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

var
  v: t (42);

begin
  p (v)
end.
