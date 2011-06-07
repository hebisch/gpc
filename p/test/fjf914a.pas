program fjf914a;

type
  t (n: Integer) = array [1 .. n] of Integer;

const
  c: array [1 .. 2] of t (2) = ((42, 17), (-4, 93));

begin
  if (c[1, 1] = 42) and
     (c[2, 1] = -4) and
     (c[1, 2] = 17) and
     (c[2, 2] = 93) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
