program fjf1054 (Output);

type
  t (n: Integer) = Integer;

var
  b, c: Integer;
  a: t (42) value 19;
  f: file of t (42);
  g: file of Integer;

begin
  Rewrite (f, 'test.dat');
  Write (f, a);
  Close (f);
  Reset (g, 'test.dat');
  Read (g, b, c);
  if (b = 42) and (c = 19) then WriteLn ('OK') else WriteLn ('failed ', b, ' ', c)
end.
