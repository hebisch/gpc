program fjf1056 (Output);

type
  t (n: Integer) = array [1 .. n] of Integer;

var
  v: ^t;

procedure p (var a: t);
begin
  if a.n = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  New (v, 42);
  p (v^)
end.
