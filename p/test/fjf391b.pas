program fjf391b;

procedure Foo (const a : Real);
begin
  if a = 42.0 then WriteLn ('OK') else WriteLn ('failed ', a)
end;

begin
  Foo (42)
end.
