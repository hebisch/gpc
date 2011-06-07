program fjf615b;

type
  t (d: Integer) = Integer;

var
  s: t (42);

begin
  s.d := 0;  { WRONG }
  WriteLn ('failed')
end.
