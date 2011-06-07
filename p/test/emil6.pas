program P (Output);

var
  A: packed array [0 .. 2] of 0 .. 1000;

function F (N: Integer): Integer;
begin
  if N = 0 then F := 0
  else begin
    A[N] := F (A[N]);
    F := A[N] + 1
  end
end;

begin
  A[0] := 1;
  A[1] := 2;
  A[2] := 0;
  A[0] := F (A[0]);
  if A[0] = 2 then WriteLn ('OK') else WriteLn ('Failed: ', A[0])
end.
