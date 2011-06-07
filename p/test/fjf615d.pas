program fjf615d;

type
  t (d: Integer) = Integer;

var
  s: t (42);

begin
  Inc (s.d);  { WRONG }
  WriteLn ('failed')
end.
