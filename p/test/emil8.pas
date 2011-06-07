program Emil8 (Output);

var
  OK: Boolean = True;

procedure Check (a, b: Complex);
var c: Integer = 0; attribute (static);
begin
  Inc (c);
  if (Abs (Re (a) - Re (b)) > 1e-6 * Abs (Re (b))) or
     (Abs (Im (a) - Im (b)) > 1e-6 * Abs (Im (b))) then
    begin
      WriteLn ('failed ', c, ' ', Re (a), ' ', Im (a), ' ', Re (b), ' ', Im (b));
      OK := False
    end
end;

begin
  Check (Cmplx (5, 0) pow 1, Cmplx (5, 0));
  Check (Cmplx (5, 0) pow 2, Cmplx (25, 0));
  Check (Cmplx (-5, 0) pow 1, Cmplx (-5, 0));
  Check (Cmplx (-5, 0) pow 2, Cmplx (25, 0));
  Check (Cmplx (5, 0) pow (-1), Cmplx (0.2, 0));
  Check (Cmplx (5, 0) pow (-2), Cmplx (0.04, 0));
  Check (Cmplx (-5, 0) pow (-1), Cmplx (-0.2, 0));
  Check (Cmplx (-5, 0) pow (-2), Cmplx (0.04, 0));

  Check (Cmplx (0, 5) pow 1, Cmplx (0, 5));
  Check (Cmplx (0, 5) pow 2, Cmplx (-25, 0));
  Check (Cmplx (0, -5) pow 1, Cmplx (0, -5));
  Check (Cmplx (0, -5) pow 2, Cmplx (-25, 0));
  Check (Cmplx (0, 5) pow (-1), Cmplx (0, -0.2));
  Check (Cmplx (0, 5) pow (-2), Cmplx (-0.04, 0));
  Check (Cmplx (0, -5) pow (-1), Cmplx (0, 0.2));
  Check (Cmplx (0, -5) pow (-2), Cmplx (-0.04, 0));

  Check (Cmplx (4, 3) pow 1, Cmplx (4, 3));
  Check (Cmplx (4, 3) pow 2, Cmplx (7, 24));
  Check (Cmplx (4, -3) pow 1, Cmplx (4, -3));
  Check (Cmplx (4, -3) pow 2, Cmplx (7, -24));
  Check (Cmplx (4, 3) pow (-1), Cmplx (0.16, -0.12));
  Check (Cmplx (4, 3) pow (-2), Cmplx (0.0112, -0.0384));
  Check (Cmplx (4, -3) pow (-1), Cmplx (0.16, 0.12));
  Check (Cmplx (4, -3) pow (-2), Cmplx (0.0112, 0.0384));

  Check (Cmplx (-4, 3) pow 1, Cmplx (-4, 3));
  Check (Cmplx (-4, 3) pow 2, Cmplx (7, -24));
  Check (Cmplx (-4, -3) pow 1, Cmplx (-4, -3));
  Check (Cmplx (-4, -3) pow 2, Cmplx (7, 24));
  Check (Cmplx (-4, 3) pow (-1), Cmplx (-0.16, -0.12));
  Check (Cmplx (-4, 3) pow (-2), Cmplx (0.0112, 0.0384));
  Check (Cmplx (-4, -3) pow (-1), Cmplx (-0.16, 0.12));
  Check (Cmplx (-4, -3) pow (-2), Cmplx (0.0112, -0.0384));

  if OK then WriteLn ('OK')
end.
