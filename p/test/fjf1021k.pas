program fjf1021k;

var
  a: Integer = 42;

type
  t (n: Integer) = Integer value a mod 4;

var
  b: t (99);

begin
  if b = 2 then WriteLn ('OK') else WriteLn ('failed ', b)
end.
