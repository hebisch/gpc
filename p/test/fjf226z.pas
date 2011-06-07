program fjf226z;
var p: ^String = nil;
begin
  if true or_else (Trim (p^) = 'foo') then WriteLn ('OK')
end.
