program fjf793h;

var
  External: Integer = 42;

procedure Foo (a, b, c: Integer);
begin
  if (a = 42) and (b = 42) and (c = 42) then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  Foo (External, External, External)
end.
