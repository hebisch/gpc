program fjf576f;

type
  t = (a, b, c);

var
  s: set of t = [1, 2];  { WRONG }

begin
  WriteLn ('failed')
end.
