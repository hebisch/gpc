program fjf527d;

const
  a: record
    a, b, c: Integer
  end = (1, 2);

begin
  if a.a < a.b then WriteLn ('OK') else WriteLn ('failed')
end.
