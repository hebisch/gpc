program fjf985;

function f: Boolean;
begin
  f := True
end;

procedure p (a: Boolean);
begin
  if a then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  p (True and f)
end.
