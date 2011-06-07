program fjf577b;

type
  t = (a, b, c);
  u = (d, e, f);

var
  s: set of t = [a .. b, e];  { WRONG }

begin
  WriteLn ('failed')
end.
