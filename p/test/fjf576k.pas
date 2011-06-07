program fjf576k;

type
  t = (a, b, c);
  u = (d, e, f);

const
  s: set of t = [d, e];  { WRONG }

begin
  WriteLn ('failed')
end.
