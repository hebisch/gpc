program fjf905b;

var
  a: record Absolute: Integer end = (42);

begin
  if a.Absolute = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
