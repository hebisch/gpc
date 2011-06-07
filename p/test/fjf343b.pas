program fjf343b;

procedure Test (const Foo : array of Char);
var i : Integer;
begin
  for i := 0 to High (Foo) do Write (Foo [i]);
  WriteLn
end;

var s : String (100) = 'OK';

begin
  Test (s)
end.
