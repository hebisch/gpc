program fjf1050b (Output);

type
  a (n: Integer) = Complex;

var
  z: a (2);

begin
  z := Cmplx (3, 4);
  if Abs (Abs (z) - 5) < 1e-6 then WriteLn ('OK') else WriteLn ('failed')
end.
