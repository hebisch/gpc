program fjf591a;

type
  t (d: Integer) = Integer;

var
  a: t (1);
  b: t (3);

begin
  if (a.d = 1) and (b.d = 3) then WriteLn ('OK') else WriteLn ('failed ', a.d, ' ', b.d)
end.
