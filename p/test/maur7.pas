program maur7;

operator ** (a, b : Integer) = c : Integer;
begin
  c := a + b
end;

operator pow (a, b : Integer) = c : Integer;
begin
  c := a - b
end;

begin
  if (42 ** 7) pow 20 = 29 then WriteLn ('OK') else WriteLn ('failed ', (42 ** 7) pow 20)
end.
