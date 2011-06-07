program fjf602;

uses GPC;

var
  i: Integer;

procedure Check (n: Integer; a, b: Real);
begin
  if (Abs (a - b) > 1e-6 * Abs (b)) then
    begin
      WriteLn ('failed ', n, ' ', i, ' ', a, ' ', b);
      Halt
    end
end;

begin
  for i := -100 to 100 do
    begin
      if i <> 0 then
        Check (1, Ln1Plus (0.5 / i), Ln (1 + 1 / (2 * i)));
      Check (2, Ln1Plus (i / 111), Ln (1 + i / 111));
      Check (3, Ln1Plus (i + 100), Ln (i + 101))
    end;
  WriteLn ('OK')
end.
