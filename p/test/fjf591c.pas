program fjf591c;

type
  t (d: Integer) = 0 .. d;

var
  a: t (1);
  b: t (3);

begin
  if (a.d = 1) and (b.d = 3) then WriteLn ('OK') else WriteLn ('failed ', a.d, ' ', b.d)
end.
