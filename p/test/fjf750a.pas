program fjf750a;

type
  Sch (I: Integer) = Char;
  T (J: Integer) = Sch (J);
  U (K: Integer) = T (K);
  S = U (2);

function G: S;
begin
  G := 'K'
end;

procedure P (a: Char);
begin
  Write (Succ (a, 4))
end;

begin
  P (G);
  WriteLn (G)
end.
