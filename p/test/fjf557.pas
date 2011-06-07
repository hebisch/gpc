program fjf557;

type
  e = (a, b, c, d);
  s = set of e;

var
  v: s;

begin
  WriteLn ('failed ', 2 in v)  { WRONG }
end.
