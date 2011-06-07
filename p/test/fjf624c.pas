program fjf624c;

type
  t (s: Integer) = array [1 .. s] of Integer;

var
  v: ^t;

procedure p (const p: array of Integer);
begin
  if (Low (p) = 0) and (High (p) = 41) then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  New (v, 42);
  p (v^)
end.
