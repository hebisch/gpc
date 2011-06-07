program fjf1021i;

var
  a: Integer = 42;

type
  i = Integer value a mod 4;
  t (n: Integer) = i;

var
  b: t (99);

begin
  if b = 2 then WriteLn ('OK') else WriteLn ('failed ', b)
end.
