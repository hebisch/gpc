program fjf569n;

procedure Test (protected a: Integer);
var
  b: type of a;
begin
  b := a + 2;
  if b = 19 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  Test (17)
end.
