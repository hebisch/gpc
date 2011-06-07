program fjf1031a (Output);

type
  t (n: Integer) = array [1 .. n] of Integer value [3: 42; otherwise 7];

var
  a: ^t;

begin
  New (a, 3);
  if (a^.n = 3) and (a^[1] = 7) and (a^[2] = 7) and (a^[3] = 42) then
    begin
      New (a, 5);
      if (a^.n = 5) and (a^[1] = 7) and (a^[2] = 7) and (a^[3] = 42) and (a^[4] = 7) and (a^[5] = 7) then
        WriteLn ('OK')
      else
        WriteLn ('failed 2')
    end
  else
    WriteLn ('failed 1')
end.
