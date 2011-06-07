program fjf624a;

type
  t (s: Integer) = array [1 .. s] of Integer;

var
  v: t (42);

procedure p (const p: array of Integer);
begin
  if (Low (p) = 0) and (High (p) = 41) then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  p (v)
end.
