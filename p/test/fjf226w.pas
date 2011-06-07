program fjf226w;

var a : ^TimeStamp = nil;

begin
  if false and_then (Time (a^) = '') then WriteLn ('failed') else WriteLn ('OK')
end.
