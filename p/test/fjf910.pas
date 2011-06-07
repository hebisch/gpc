program fjf910;

type
  t = record
    a: Boolean;
    b: Integer;
  end;

var
  v: Integer = 42;

begin
  if v = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
