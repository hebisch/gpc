{ `Sqr (i)' gets expanded to `i * i', but the user-defined operator
  must not be applied to it. }

program fjf991;

var
  i: Integer = 4;

operator * (a, b: Integer) = c: Integer;
begin
  c := a + b
end;

begin
  if Sqr (i) = 16 then WriteLn ('OK') else WriteLn ('failed ', Sqr (4))
end.
