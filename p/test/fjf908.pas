program fjf908;

var
  n: Integer = 0;

procedure Check (a, b: Integer);
begin
  Inc (n);
  if a <> b then
    begin
      WriteLn ('failed ', n, ' ', a, ' ', b);
      Halt
    end
end;

procedure CheckR (a, b: Real);
begin
  Inc (n);
  if Abs (a - b) > 1e-6 * Max (Abs (a), Abs (b)) then
    begin
      WriteLn ('failed ', n, ' ', a, ' ', b);
      Halt
    end
end;

begin
  Check (0 pow 1, 0);
  Check (0 pow 2, 0);
  Check (1 pow (-2), 1);
  Check (1 pow (-1), 1);
  Check (1 pow 0, 1);
  Check (1 pow 1, 1);
  Check (1 pow 2, 1);
  Check ((-1) pow (-2), 1);
  Check ((-1) pow (-1), -1);
  Check ((-1) pow 0, 1);
  Check ((-1) pow 1, -1);
  Check ((-1) pow 2, 1);
  Check (2 pow (-2), 0);
  Check (2 pow (-1), 0);
  Check (2 pow 0, 1);
  Check (2 pow 1, 2);
  Check (2 pow 2, 4);
  Check ((-2) pow (-2), 0);
  Check ((-2) pow (-1), 0);
  Check ((-2) pow 0, 1);
  Check ((-2) pow 1, -2);
  Check ((-2) pow 2, 4);
  Check (3 pow (-2), 0);
  Check (3 pow (-1), 0);
  Check (3 pow 0, 1);
  Check (3 pow 1, 3);
  Check (3 pow 2, 9);
  Check ((-3) pow (-2), 0);
  Check ((-3) pow (-1), 0);
  Check ((-3) pow 0, 1);
  Check ((-3) pow 1, -3);
  Check ((-3) pow 2, 9);

  CheckR (0 ** 1, 0);
  CheckR (0 ** 2, 0);
  CheckR (1 ** (-2), 1);
  CheckR (1 ** (-1), 1);
  CheckR (1 ** 0, 1);
  CheckR (1 ** 1, 1);
  CheckR (1 ** 2, 1);
  CheckR (2 ** (-2), 0.25);
  CheckR (2 ** (-1), 0.5);
  CheckR (2 ** 0, 1);
  CheckR (2 ** 1, 2);
  CheckR (2 ** 2, 4);
  CheckR (3 ** (-2), 1/9);
  CheckR (3 ** (-1), 1/3);
  CheckR (3 ** 0, 1);
  CheckR (3 ** 1, 3);
  CheckR (3 ** 2, 9);

  CheckR (0.0 pow 1, 0);
  CheckR (0.0 pow 2, 0);
  CheckR (1.0 pow (-2), 1);
  CheckR (1.0 pow (-1), 1);
  CheckR (1.0 pow 0, 1);
  CheckR (1.0 pow 1, 1);
  CheckR (1.0 pow 2, 1);
  CheckR ((-1.0) pow (-2), 1);
  CheckR ((-1.0) pow (-1), -1);
  CheckR ((-1.0) pow 0, 1);
  CheckR ((-1.0) pow 1, -1);
  CheckR ((-1.0) pow 2, 1);
  CheckR (2.0 pow (-2), 0.25);
  CheckR (2.0 pow (-1), 0.5);
  CheckR (2.0 pow 0, 1);
  CheckR (2.0 pow 1, 2);
  CheckR (2.0 pow 2, 4);
  CheckR ((-2.0) pow (-2), 0.25);
  CheckR ((-2.0) pow (-1), -0.5);
  CheckR ((-2.0) pow 0, 1);
  CheckR ((-2.0) pow 1, -2);
  CheckR ((-2.0) pow 2, 4);
  CheckR (3.0 pow (-2), 1/9);
  CheckR (3.0 pow (-1), 1/3);
  CheckR (3.0 pow 0, 1);
  CheckR (3.0 pow 1, 3);
  CheckR (3.0 pow 2, 9);
  CheckR ((-3.0) pow (-2), 1/9);
  CheckR ((-3.0) pow (-1), -1/3);
  CheckR ((-3.0) pow 0, 1);
  CheckR ((-3.0) pow 1, -3);
  CheckR ((-3.0) pow 2, 9);

  CheckR (0.0 ** 1, 0);
  CheckR (0.0 ** 2, 0);
  CheckR (1.0 ** (-2), 1);
  CheckR (1.0 ** (-1), 1);
  CheckR (1.0 ** 0, 1);
  CheckR (1.0 ** 1, 1);
  CheckR (1.0 ** 2, 1);
  CheckR (2.0 ** (-2), 0.25);
  CheckR (2.0 ** (-1), 0.5);
  CheckR (2.0 ** 0, 1);
  CheckR (2.0 ** 1, 2);
  CheckR (2.0 ** 2, 4);
  CheckR (3.0 ** (-2), 1/9);
  CheckR (3.0 ** (-1), 1/3);
  CheckR (3.0 ** 0, 1);
  CheckR (3.0 ** 1, 3);
  CheckR (3.0 ** 2, 9);

  WriteLn ('OK')
end.
