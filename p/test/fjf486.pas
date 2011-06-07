program fjf486;

begin
  if (2 pow 31 < 0) or (2 pow 31 <> $80000000) then WriteLn ('failed ', 2 pow 31) else WriteLn ('OK')
end.
