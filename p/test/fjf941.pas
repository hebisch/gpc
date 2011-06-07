program fjf941;

const
  b3: array [1 .. 1] of Integer = (((3)) + 4);
  b2: array [1 .. 2, 1 .. 1, 1 .. 1] of Integer = (((3)),((2)));

begin
  if (b3[1] = 7) and (b2[1, 1, 1] = 3) and (b2[2, 1, 1] = 2) then WriteLn ('OK') else WriteLn ('failed')
end.
