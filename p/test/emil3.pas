program SqrtTest (Output);

var
  C: Complex;

begin
  C := Sqrt (Cmplx (4.2, 1e-8));
  if (Abs (Re (C) - 2.0493901531919) < 1e-6) and (Abs (Im (C)) < 1e-6) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', Re (C), ' ', Im (C))
end.
