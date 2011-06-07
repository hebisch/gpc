program fjf601a;

procedure p (protected a: Integer);
begin
  if a = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

var
  v: ^procedure (protected a: Integer) = @p;

begin
  v^ (42)
end.
