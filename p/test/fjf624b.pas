program fjf624b;

type
  t (s: Integer) = array [1 .. s] of Integer;

var
  v: t (42);

procedure p (const p: array [m .. n: Integer] of Integer);
begin
  if (m = 1) and (n = 42) and (Low (p) = 1) and (High (p) = 42) then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  p (v)
end.
