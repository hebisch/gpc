program fjf723e;

var
  z: Complex;

begin
  z := Conjugate (Cmplx (3.5, 4.25));
  if (Re (z) = 3.5) and (Im (z) = -4.25) then WriteLn ('OK') else WriteLn ('failed')
end.
