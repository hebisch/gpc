program fjf793i;

procedure Foo (var External; i: Integer);
begin
  if i = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  Foo (Null, 42)
end.
