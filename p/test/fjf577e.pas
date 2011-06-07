program fjf577e;

type
  t = (a, b, c);
  u = (d, e, f);

var
  s: set of t;

begin
  s := [d .. f, e];  { WRONG }
  WriteLn ('failed')
end.
