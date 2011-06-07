program fjf914b;

type
  t (n: Integer) = array [1 .. n] of Integer;
  u (m: Integer) = t (m);

const
  c: u (3) = (42, -4, 93);

begin
  if (c[1] = 42) and
     (c[2] = -4) and
     (c[3] = 93) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
