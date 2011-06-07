program fjf344;

procedure Foo (const z : Complex);
begin
  if z = Cmplx (42, -17) then WriteLn ('OK') else WriteLn ('failed')
end;

function Bar : Complex;
begin
  Bar := Cmplx (42, -17)
end;

begin
  Foo (Bar)
end.
