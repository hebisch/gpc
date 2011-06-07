program fjf577a;

type
  t = (a, b, c);
  u = (d, e, f);

var
  s: set of t = [b .. e];  { WRONG }

begin
  WriteLn ('failed')
end.
