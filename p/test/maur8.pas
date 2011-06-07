program maur8;

var
  x: Real;
  z: Complex;
  OK: Boolean = True;

procedure Check (a, b: Real);
var c: Integer = 0; attribute (static);
begin
  Inc (c);
  if Abs (a / b - 1) > 1e-6 then
    begin
      WriteLn ('failed ', c, ' ', a, ' ', b);
      OK := False
    end
end;

begin
  x := MaxReal ** 0.7;
  z := Cmplx (x, 2 * x);
  Check (Abs (z), SqRt (5) * x);
  Check (Re (Ln (z)), Ln (5) / 2 + Ln (x));
  Check (Im (Ln (z)), ArcTan (2));
  if OK then WriteLn ('OK')
end.
