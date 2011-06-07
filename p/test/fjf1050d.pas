program fjf1050d (Output);

type
  a (n: Integer) = Integer;
  b (a, b, c, d, e: Integer) = Integer;

var
  i: a (2);
  p: ^b;

begin
  i := 42;
  New (p, i, i, i, i, i);
  if p^.e = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
