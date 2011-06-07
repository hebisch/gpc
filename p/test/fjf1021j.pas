program fjf1021j;

uses fjf1021u;

type
  t (n: Integer) = Integer value a mod 4;

var
  b: t (99);

begin
  if b = 2 then WriteLn ('OK') else WriteLn ('failed ', b)
end.
