program fjf556b;

type
  e = Char;
  s = set of e;

var
  v, w: s;

begin
  v := ['b', 'c'];
  w := ['c', 'd'];
  if v = w - ['d'] + ['b'] then WriteLn ('OK') else WriteLn ('failed')
end.
