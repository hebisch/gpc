program fjf391a;

procedure Foo (const a : Real);
begin
  if a = 42.0 then WriteLn ('OK') else WriteLn ('failed ', a)
end;

var
  a : Integer = 42;

begin
  Foo (a)
end.
