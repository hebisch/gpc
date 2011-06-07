program adam3t;

procedure at(protected i: byte);
begin
  if 4 in [i .. 10] then WriteLn ('failed') else WriteLn ('OK')
end;

begin
  at (5)
end.
