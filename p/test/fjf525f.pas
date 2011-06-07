program fjf525f;

var
  p: Byte;
  c: Integer;

begin
  c := 0;
  for p := 10 downto 1 do Inc (c);
  if c <> 10 then
    WriteLn ('failed ', c, ' (expected ', 10, ')')
  else
    WriteLn ('OK')
end.
