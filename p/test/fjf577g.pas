program fjf577g;

type
  t = (a, b, c);
  u = (d, e, f);

var
  s: set of t = [d .. e, f];  { WRONG }

begin
  WriteLn ('failed')
end.
