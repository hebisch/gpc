program fjf587c;

type
  t = String (42);

function Foo: t;
var
  c: Char = 'O';
begin
  Foo := c
end;

begin
  WriteLn (Foo, 'K')
end.
