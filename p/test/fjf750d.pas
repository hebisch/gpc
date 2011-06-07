program fjf750d;

type
  Sch (I: Integer) = record F: Char end;
  T (J: Integer) = Sch (J);
  U (K: Integer) = T (K);
  S = U (2);

procedure G (var X: S);
begin
  X.F := 'K'
end;

procedure P (a: Char);
begin
  Write (Succ (a, 4))
end;

var
  Y: S;

begin
  Y.F := 'X';
  G (Y);
  P (Y.F);
  WriteLn (Y.F)
end.
