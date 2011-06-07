program fjf576e;

type
  t = (a, b, c);
  u = (d, e, f);

var
  s: set of t;

begin
  s := [d, e];  { WRONG }
  WriteLn ('failed')
end.
