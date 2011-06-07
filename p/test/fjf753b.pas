program fjf753b;
var s: String (100);
begin
  WriteStr (s, '1' : 0, '22' : 0, 3 : 0);
  if s = '3' then WriteLn ('OK') else WriteLn ('failed')
end.
