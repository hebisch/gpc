program fjf905a;

var
  a: record Value: Integer end = (42);

begin
  if a.Value = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
