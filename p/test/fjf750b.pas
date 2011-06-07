program fjf750b;

type
  Sch (I: Integer) = record F: Char end;
  T (J: Integer) = Sch (J);
  U (K: Integer) = T (K);
  S = U (2);

function G = R: S;
begin
  R.F := 'K'
end;

procedure P (a: Char);
begin
  Write (Succ (a, 4))
end;

begin
  P (G.F);
  WriteLn (G.F)
end.
