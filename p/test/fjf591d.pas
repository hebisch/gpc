program fjf591d;

type
  t (d: Integer) = 0 .. d;

var
  a: ^t;
  b: t (3);

begin
  New (a, 2);
  if (a^.d = 2) and (b.d = 3) then WriteLn ('OK') else WriteLn ('failed ', a^.d, ' ', b.d)
end.
