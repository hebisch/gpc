program fjf556d;

type
  e = (a, b, c, d);

var
  x: set of b .. c;

begin
  if Min (c, Low (x)) = b then WriteLn ('OK') else WriteLn ('failed')
end.
