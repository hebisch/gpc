program fjf970b;

const
  a = Index ('abc', 'b');
  b = Index ('abc', 'd');
  c = Index ('abc', 'ab');
  d = Index ('abc', 'ac');
  e = Index ('b', 'b');
  f = Index ('c', 'b');
  g = Index ('d', 'dd');
  h = Index ('e', 'e'#0);
  i = Index ('', '');
  j = Index ('b', '');
  k = Index ('bc', '');
  l = Index ('', 'd');
  m = Index ('', 'de');

begin
  if (a = 2) and (b = 0) and (c = 1) and (d = 0) and (e = 1) and (f = 0) and (g = 0) and (h = 0)
     and (i = 1) and (j = 1) and (k = 1) and (l = 0) and (m = 0) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
