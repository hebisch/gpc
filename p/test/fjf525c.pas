program fjf525c;

var
  p: Byte;
  c: Integer;

begin
  c := 0;
  for p := 1 to 10 do Inc (c);
  if c <> 10 then
    WriteLn ('failed ', c, ' (expected ', 10, ')')
  else
    WriteLn ('OK')
end.
