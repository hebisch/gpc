program Emil9;

const
  Eps = 1e6 * MinReal;
  A = 1e17;
  BR = SqRt (MaxReal);

var
  OK: Boolean = True;
  B, B2: Real;

procedure Check (z1, z2: Complex);
var c: Integer = 0; attribute (static);
begin
  Inc (c);
  if (Abs (Re (z1) - Re (z2)) > 1e-8 * Abs (Re (z2))) or
     (Abs (Im (z1) - Im (z2)) > 1e-8 * Abs (Im (z2))) then
    begin
      WriteLn ('failed ', c, ' ', Re (z1), ' ', Im (z1), ' ', Re (z2), ' ', Im (z2));
      OK := False
    end
end;

procedure Check1 (x, y, v, w: Real);
begin
  Check (ArcTan (Cmplx (x, y)), Cmplx (v, w))
end;

begin
  { Make sure that both B and 1 / B are valid numbers }
  if MaxReal * MinReal <= 1 then  { i.e., MaxReal <= 1 / MinReal, but 1 / MinReal might overflow }
    B := MaxReal
  else
    B := 1 / MinReal;
  B2 := B / 2;
  { Note: The "correct" values (on the right side) are not
    absolutely exact, but the real error is much smaller than the
    relative margin (1e-8, above) allowed for floating-point
    inaccuracies. }
  Check1 ( 0,  0,       0, 0);
  Check1 ( 1,  0,  Pi / 4, 0);
  Check1 (-1,  0, -Pi / 4, 0);
  Check1 ( 1,  1, (Pi - ArcTan (2)) / 2,  Ln (5) / 4);
  Check1 (-1, -1, (ArcTan (2) - Pi) / 2, -Ln (5) / 4);
  Check1 ( 1, -1, (Pi - ArcTan (2)) / 2, -Ln (5) / 4);
  Check1 (-1,  1, (ArcTan (2) - Pi) / 2,  Ln (5) / 4);
  Check1 ( Eps,    0,  ArcTan (Eps), 0);
  Check1 (-Eps,    0, -ArcTan (Eps), 0);
  Check1 (   0,  Eps, 0,  Eps);
  Check1 (   0, -Eps, 0, -Eps);
  Check1 ( Eps,    1,  Pi / 4, (Ln (2) - Ln (Eps)) / 2);
  Check1 ( Eps,   -1,  Pi / 4, (Ln (Eps) - Ln (2)) / 2);
  Check1 (-Eps,    1, -Pi / 4, (Ln (2) - Ln (Eps)) / 2);
  Check1 (-Eps,   -1, -Pi / 4, (Ln (Eps) - Ln (2)) / 2);
  Check1 (   1,  Eps,  Pi / 4,  Eps / 2);
  Check1 (  -1,  Eps, -Pi / 4,  Eps / 2);
  Check1 (   1, -Eps,  Pi / 4, -Eps / 2);
  Check1 (  -1, -Eps, -Pi / 4, -Eps / 2);
  Check1 ( Eps,  Eps,  ArcTan (2 * Eps) / 2,  Eps);
  Check1 (-Eps, -Eps, -ArcTan (2 * Eps) / 2, -Eps);
  Check1 ( Eps, -Eps,  ArcTan (2 * Eps) / 2, -Eps);
  Check1 (-Eps,  Eps, -ArcTan (2 * Eps) / 2,  Eps);
  Check1 (   A,    0,  ArcTan (A), 0);
  Check1 (  -A,    0, -ArcTan (A), 0);
  Check1 (   0,    A,  Pi / 2,  1 / A);
  Check1 (   0,   -A,  Pi / 2, -1 / A);
  Check1 (   A,    1,  Pi / 2,  1 / Sqr (A));
  Check1 (   A,   -1,  Pi / 2, -1 / Sqr (A));
  Check1 (  -A,    1, -Pi / 2,  1 / Sqr (A));
  Check1 (  -A,   -1, -Pi / 2, -1 / Sqr (A));
  Check1 (   1,    A,  Pi / 2,  1 / A);
  Check1 (  -1,    A, -Pi / 2,  1 / A);
  Check1 (   1,   -A,  Pi / 2, -1 / A);
  Check1 (  -1,   -A, -Pi / 2, -1 / A);
  Check1 (   A,    A,  Pi / 2,  1 / (2 * A));
  Check1 (  -A,    A, -Pi / 2,  1 / (2 * A));
  Check1 (   A,   -A,  Pi / 2, -1 / (2 * A));
  Check1 (  -A,   -A, -Pi / 2, -1 / (2 * A));
  Check1 ( Eps,    A,  Pi / 2,  1 / A);
  Check1 ( Eps,   -A,  Pi / 2, -1 / A);
  Check1 (-Eps,    A, -Pi / 2,  1 / A);
  Check1 (-Eps,   -A, -Pi / 2, -1 / A);
  Check1 (   A,  Eps,  Pi / 2,  Eps / Sqr (A));
  Check1 (  -A,  Eps, -Pi / 2,  Eps / Sqr (A));
  Check1 (   A, -Eps,  Pi / 2, -Eps / Sqr (A));
  Check1 (  -A, -Eps, -Pi / 2, -Eps / Sqr (A));
  Check1 (1000, 0.0001, (Pi - ArcTan (2000 / 999998.99999999)) / 2, 9.99999e-11);
  Check1 (   B,    0,  ArcTan (B), 0);
  Check1 (  -B,    0, -ArcTan (B), 0);
  Check1 (   0,    B,  Pi / 2,  1 / B);
  Check1 (   0,   -B,  Pi / 2, -1 / B);
  Check1 (  BR,    1,  Pi / 2,  1 / Sqr (BR));
  Check1 (  BR,   -1,  Pi / 2, -1 / Sqr (BR));
  Check1 ( -BR,    1, -Pi / 2,  1 / Sqr (BR));
  Check1 ( -BR,   -1, -Pi / 2, -1 / Sqr (BR));
  Check1 (   1,    B,  Pi / 2,  1 / B);
  Check1 (  -1,    B, -Pi / 2,  1 / B);
  Check1 (   1,   -B,  Pi / 2, -1 / B);
  Check1 (  -1,   -B, -Pi / 2, -1 / B);
  Check1 (  B2,   B2,  Pi / 2,  1 / (2 * B2));
  Check1 ( -B2,   B2, -Pi / 2,  1 / (2 * B2));
  Check1 (  B2,  -B2,  Pi / 2, -1 / (2 * B2));
  Check1 ( -B2,  -B2, -Pi / 2, -1 / (2 * B2));
  Check1 ( Eps,    B,  Pi / 2,  1 / B);
  Check1 ( Eps,   -B,  Pi / 2, -1 / B);
  Check1 (-Eps,    B, -Pi / 2,  1 / B);
  Check1 (-Eps,   -B, -Pi / 2, -1 / B);
  Check1 (  BR,  Eps,  Pi / 2,  Eps / Sqr (BR));
  Check1 ( -BR,  Eps, -Pi / 2,  Eps / Sqr (BR));
  Check1 (  BR, -Eps,  Pi / 2, -Eps / Sqr (BR));
  Check1 ( -BR, -Eps, -Pi / 2, -Eps / Sqr (BR));
  if OK then WriteLn ('OK')
end.
