program fjf226y;
var p: ^String = nil;
begin
  if true or_else (SubStr (p^, -1, 1) = 'foo') then WriteLn ('OK')
end.
