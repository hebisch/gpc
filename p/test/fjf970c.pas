program fjf970c;

const
  a = Pos ('b', 'abc');
  b = Pos ('d', 'abc');
  c = Pos ('ab', 'abc');
  d = Pos ('ac', 'abc');
  e = Pos ('b', 'b');
  f = Pos ('b', 'c');
  g = Pos ('dd', 'd');
  h = Pos ('e'#0, 'e');
  i = Pos ('', '');
  j = Pos ('', 'b');
  k = Pos ('', 'bc');
  l = Pos ('d', '');
  m = Pos ('de', '');

begin
  if (a = 2) and (b = 0) and (c = 1) and (d = 0) and (e = 1) and (f = 0) and (g = 0) and (h = 0)
     and (i = 1) and (j = 1) and (k = 1) and (l = 0) and (m = 0) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
