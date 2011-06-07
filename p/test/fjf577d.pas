program fjf577d;

type
  t = (a, b, c);

var
  s: set of t;

begin
  s := [1 .. 3, 2];  { WRONG }
  WriteLn ('failed')
end.
