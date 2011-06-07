program fjf750c;

type
  Sch (I: Integer) = Char;
  T (J: Integer) = Sch (J);
  U (K: Integer) = T (K);
  S = U (2);

procedure G (var X: S);
begin
  X := 'K'
end;

procedure P (a: Char);
begin
  Write (Succ (a, 4))
end;

var
  Y: S;

begin
  Y := 'X';
  G (Y);
  P (Y);
  WriteLn (Y)
end.
