program SchemaFunc (Output);

type
  Sch (I: Integer) = array [1 .. I] of Integer;
  T (J: Integer) = Sch (J);
  S = T (13);

var
  A, B: S;

function G: S;
begin
  G := A
end;

begin
  A[7] := 42;
  B := G;
  if (G[7] = 42) and (B[7] = 42) then WriteLn ('OK')
  else WriteLn ('failed')
end.
