program fjf226v;

var a : ^TimeStamp = nil;

begin
  if false and_then (Date (a^) = '') then WriteLn ('failed') else WriteLn ('OK')
end.
