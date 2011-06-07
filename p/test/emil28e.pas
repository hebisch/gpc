program Test (output);

type
  t (Dummy: Integer) = record
    f: Integer value 42
  end;

var
  a: t (3);

begin
  if a.f = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
