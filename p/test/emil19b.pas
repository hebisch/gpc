program Emil19b (Output);

type
  A (k: Integer) = 1..7;
  B (N: Integer) = A (N);

var
  C : B (7);

begin
  if (C.N = 7) and (C.k = 7) then WriteLn ('OK')
      else WriteLn ('failed: ', C.N, ' ', C.k)
end.
