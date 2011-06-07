program fjf577c;

type
  t = (a, b, c);

var
  s: set of t = [a .. c, 2 .. 3];  { WRONG }

begin
  WriteLn ('failed')
end.
