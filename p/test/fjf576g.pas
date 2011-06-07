program fjf576g;

type
  t = (a, b, c);
  u = (d, e, f);

var
  s: set of t = [d, e];  { WRONG }

begin
  WriteLn ('failed')
end.
