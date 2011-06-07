program fjf541b;

const
  Eps = 1e-14;

function RealEQ (const a, b: LongestReal): Boolean;
begin
  RealEQ := Abs (a - b) <= Eps * (SqRt (Sqr (a) + Sqr (b)) + 1)
end;

procedure Check (const a, b: Complex);
var n: Integer = 0; attribute (static);
begin
  Inc (n);
  if not RealEQ (Re (a), Re (b)) or not RealEQ (Im (a), Im (b)) then
    begin
      Writeln ('failed ', n, ': ', Re (a):0:4, '+', Im (a):0:4, 'i (',
               Re (b):0:4, '+', Im (b):0:4, 'i)');
      Halt
    end
end;

begin
  Check (Polar (2.0, Pi / 2), Cmplx (0.0, 2.0));
  Check (Polar (2.0, Pi / 2), Cmplx (0.0, 2));
  Check (Polar (2.0, Pi / 2), Cmplx (0, 2.0));
  Check (Polar (2.0, Pi / 2), Cmplx (0, 2));
  Check (Polar (2, Pi / 2), Cmplx (0, 2));
  Check (Polar (3.0, 2.0), Cmplx (3 * Cos (2), 3 * Sin (2)));
  Check (Polar (3.0, 2), Cmplx (3 * Cos (2), 3 * Sin (2)));
  Check (Polar (3, 2.0), Cmplx (3 * Cos (2), 3 * Sin (2)));
  Check (Polar (3, 2), Cmplx (3 * Cos (2), 3 * Sin (2)));
  Writeln ('OK')
end.
