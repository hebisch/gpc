program fjf604;

type
  p = ^t;
  t (d: Integer) = record end;

procedure b (a: p); forward;

procedure b (a: p);
begin
  if a^.d = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

var
  c: t (42);

begin
  b (@c)
end.
