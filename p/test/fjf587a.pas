program fjf587a;

procedure Foo;
var
  c: Char = 'O';
  d: Char = 'K';
  s: String (42) = c;
  t: String (42);
begin
  t := d;
  WriteLn (s, t)
end;

begin
  Foo
end.
