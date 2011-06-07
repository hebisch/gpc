program fjf665k;

var
  Called: Integer = 0;

function Foo: Boolean;
begin
  Inc (Called);
  Foo := True
end;

begin
  Assert (Foo);
  if Called = 1 then WriteLn ('OK') else WriteLn ('failed')
end.
