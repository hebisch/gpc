program fjf577j;

type
  t = (a, b, c);

const
  s: set of t = [1 .. 2, 3];  { WRONG }

begin
  WriteLn ('failed')
end.
