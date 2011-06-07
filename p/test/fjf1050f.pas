program fjf1050f (Output);

type
  b (n: Integer) = Integer;
  a (n: Integer) = file of b (2);

var
  f: a (2);
  i: b (2);
  j: b (2);

begin
  i := 42;
  Rewrite (f);
  Write (f, i);
  Reset (f);
  Read (f, j);
  if j = 42 then WriteLn ('OK') else WriteLn ('failed ', j)
end.
