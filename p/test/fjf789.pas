program fjf789;

type
  t = record x: Integer end;

operator <= (a: t; b: Real) = c: Boolean;
begin
  c := True
end;

operator <= (a: t; b: LongReal) = c: Boolean;
begin
  c := True
end;

var
  v: t;

begin
  if v <= 1/4 then WriteLn ('OK')
end.
