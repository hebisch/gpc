program fjf576b;

type
  t = (a, b, c);
  u = (d, e, f);

var
  s: set of t = [a, e];  { WRONG }

begin
  WriteLn ('failed')
end.
