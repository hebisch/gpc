program Emil19a (Output);

type
  A (N: Integer) = Integer;
  B (N: Integer) = array [1 .. N] of A (N);

var
  C : B (7);

begin
  if (C.N = 7) and (C[3].N = 7) then WriteLn ('OK')
      else WriteLn ('failed: ', C.N, ' ', C[3].N)
end.
