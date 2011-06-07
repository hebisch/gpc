program fjf1050a (Output);

type
  a (n: Integer) = Integer;

var
  i: a (2);

begin
  i := 4;
  if Sqr (i) = 16 then WriteLn ('OK') else WriteLn ('failed')
end.
