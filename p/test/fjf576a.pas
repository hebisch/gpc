program fjf576a;

type
  t = (a, b, c);
  u = (d, e, f);

var
  s: set of t = [b .. 3];  { WRONG }

begin
  WriteLn ('failed')
end.
