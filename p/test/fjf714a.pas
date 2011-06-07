program fjf714a;

var
  a, b: Real;

begin
  a := 3;
  Inc (a, 2.5);
  b := a;
  Dec (b, 4);
  if (a = 5.5) and (b = 1.5) and (Succ (a, -3.5) = 2) and (Pred (b, 2) = -0.5) then
    WriteLn ('OK') else WriteLn ('failed')
end.
