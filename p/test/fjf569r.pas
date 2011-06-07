program fjf569r;

type
  t = set of 1 .. 100;

procedure foo (const a: t);
begin
  if a = [99, 88] then WriteLn ('OK') else WriteLn ('failed')
end;

var
  a: procedure (const s: t) = foo;

begin
  a ([88, 99])
end.
