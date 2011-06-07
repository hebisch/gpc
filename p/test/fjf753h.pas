program fjf753h;
var s: String (100);
begin
  WriteStr (s, '1' : -3);
  if s = '1  ' then WriteLn ('OK') else WriteLn ('failed')
end.
