program fjf576c;

type
  t = (a, b, c);

var
  s: set of t = [a, 2];  { WRONG }

begin
  WriteLn ('failed')
end.
