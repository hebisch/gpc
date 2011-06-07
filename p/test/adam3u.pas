program adam3u;

procedure at(const i: byte);
begin
  if 4 in [2 .. i] then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  at (5)
end.
