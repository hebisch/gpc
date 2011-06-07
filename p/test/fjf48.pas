program fjf48;
var
  a:procedure;
  b:integer absolute a;
begin
  if Pointer (@b) = @@a then WriteLn ('OK') else WriteLn ('failed')
end.
