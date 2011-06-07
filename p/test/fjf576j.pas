program fjf576j;

type
  t = (a, b, c);

const
  s: set of t = [1, 2];  { WRONG }

begin
  WriteLn ('failed')
end.
