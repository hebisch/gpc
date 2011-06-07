program fjf974c;

type
  a = Integer value 42;
  t = array [1 .. 2, 1 .. 2] of a value [otherwise [otherwise 17]];

var
  v: t;

begin
  if (v[1, 2] = 17) and (v[1, 2] = 17) then WriteLn ('OK') else WriteLn ('failed')
end.
