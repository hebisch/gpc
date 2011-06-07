program fjf1050e (Output);

type
  a (n: Integer) = Text;
  b (n: Integer) = Integer;

var
  f: a (2);
  i: b (2);
  j: b (3);

begin
  i := 42;
  Rewrite (f);
  WriteLn (f, i);
  Reset (f);
  ReadLn (f, j);
  if j = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
