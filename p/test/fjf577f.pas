program fjf577f;

type
  t = (a, b, c);

var
  s: set of t = [1 .. 2, 3];  { WRONG }

begin
  WriteLn ('failed')
end.
