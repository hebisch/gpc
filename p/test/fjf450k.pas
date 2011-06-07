program fjf450k;

var
  a: Integer;

begin
  a := Integer ('x');
  if a = Ord ('x') then WriteLn ('OK') else WriteLn ('failed')
end.
