program fjf343a;

procedure Test (const Foo : array [m .. n : Integer] of Char);
var i : Integer;
begin
  for i := m to n do Write (Foo [i]);
  WriteLn
end;

var s : String (100) = 'OK';

begin
  Test (s)
end.
