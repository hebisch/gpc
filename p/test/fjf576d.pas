program fjf576d;

type
  t = (a, b, c);

var
  s: set of t;

begin
  s := [1, 2];  { WRONG }
  WriteLn ('failed')
end.
