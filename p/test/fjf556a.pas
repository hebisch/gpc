program fjf556a;

type
  e = Byte;
  s = set of e;

var
  v, w: s;

begin
  v := [4, 9];
  w := [4, 6];
  if v = w - [6] + [9] then WriteLn ('OK') else WriteLn ('failed')
end.
