program fjf1016e (Output);

var
  v: record
    a: Integer value 42
  end;

begin
  if v.a = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
