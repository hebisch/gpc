program Emil18 (Output);

const
  Two = 2;

begin
  if (0 < Two - 23) or (3 < 13 - 42) then
    WriteLn ('failed: ', Two - 23, ', ', 13 - 42)
  else WriteLn ('OK')
end.
