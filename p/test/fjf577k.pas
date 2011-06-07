program fjf577k;

type
  t = (a, b, c);
  u = (d, e, f);

const
  s: set of t = [d .. e, f];  { WRONG }

begin
  WriteLn ('failed')
end.
