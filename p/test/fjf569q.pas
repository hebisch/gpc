program fjf569q;

procedure foo (const a: Real);
begin
  if a = 10e4 then WriteLn ('OK') else WriteLn ('failed')
end;

var
  a: procedure (const s: Real) = foo;

begin
  a (1e5)
end.
