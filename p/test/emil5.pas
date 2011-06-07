program Emil5 (Output);

type
  T = packed array [0 .. 2] of 0 .. 1000;

var
  A: T value (1, 2, 0);

begin
  if (A[0] = 1) and (A[1] = 2) and (A[2] = 0) then WriteLn ('OK')
  else WriteLn ('Failed: ', A[0] : 4, A[1] : 4, A[2] : 4)
end.
