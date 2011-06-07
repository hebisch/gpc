program fjf624d;

type
  t (s: Integer) = array [1 .. s] of Integer;

var
  v: ^t;

procedure p (const p: array [m .. n: Integer] of Integer);
begin
  if (m = 1) and (n = 42) and (Low (p) = 1) and (High (p) = 42) then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  New (v, 42);
  p (v^)
end.
