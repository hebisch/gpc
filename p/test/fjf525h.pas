program fjf525h;

var
  p: Byte;
  c: Integer;

begin
  c := 0;
  for p in [2, 10, 12, 14] do Inc (c);
  if c <> 4 then
    WriteLn ('failed: ', c)
  else
    WriteLn ('OK')
end.
