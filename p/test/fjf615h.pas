program fjf615h;

type
  t (d: Integer) = Integer;

var
  s: t (42);

begin
  ReadStr ('', s.d);  { WRONG }
  WriteLn ('failed')
end.
