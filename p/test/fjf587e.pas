program fjf587e;

type
  t = String (42);

function Foo: t;
var
  c: Char = 'O';
begin
  return c + 'K'
end;

begin
  WriteLn (Foo)
end.
