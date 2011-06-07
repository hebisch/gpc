program fjf1002 (Output);

var
  a: Complex;
  r: Real;
  i: Integer;
  n: Integer = 0;

procedure c (d, e: Real);
begin
  Inc (n);
  if (Abs (Re (a) - d) > 0.001) or (Abs (Im (a) - e) > 0.001) then
    WriteLn ('failed ', n, ' ', Re (a), ' ', Im (a), ' ', d, ' ', e)
end;

begin
  a := Cmplx (10, 20);
  r := 9;
  a := a + r;
  c (19, 20);
  i := 3;
  a := i + a;
  c (22, 20);
  a := a - 4.2;
  c (17.8, 20);
  r := 50;
  a := r - a;
  c (32.2, -20);
  a := (i - 1) * a;
  c (64.4, -40);
  a := a * i;
  c (193.2, -120);
  a := a / r;
  c (3.864, -2.4);
  a := i / a;
  c (0.560257, 0.347986);
  WriteLn ('OK')
end.
