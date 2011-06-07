program fjf232a;

var
  X, Y, Z: Integer;

operator + (var a, b: Integer) = c: Integer;
begin
  Inc (a, b);
  c := a
end;

begin
  X := 7;
  Z := 35;
  Y := X + Z;
  if X = 42 then
    WriteLn ('OK')
  else
    WriteLn ('failed ', X)
end.
