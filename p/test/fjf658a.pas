program fjf658a;

var
  a: ^Real;
  z: Complex;

begin
  z := Cmplx (0, 0);
  a := @Re (z);  { WRONG }
  WriteLn ('failed')
end.
