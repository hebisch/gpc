program fjf788;

procedure Foo;
var
  a: Integer; attribute (register);
  b: ^Integer;
begin
  b := @a  { WARN }
end;

begin
end.
