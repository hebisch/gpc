program fjf475;

procedure p (b : WordBool);
begin
  if b then WriteLn ('failed') else WriteLn ('OK')
end;

begin
  p (False)
end.
