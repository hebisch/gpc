program fjf587b;

procedure Foo;
var
  c: Char = 'O';
  s: String (42) = c + 'K';
begin
  WriteLn (s)
end;

begin
  Foo
end.
