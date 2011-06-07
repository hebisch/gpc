program fjf658b;

var
  a: ^Real;
  z: Complex;

begin
  z := Cmplx (0, 0);
  a := @Im (z);  { WRONG }
  WriteLn ('failed')
end.
