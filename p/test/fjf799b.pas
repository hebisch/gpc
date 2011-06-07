program fjf799b;

var
  forward: String (2);

procedure Foo; forward;

procedure Foo;
begin
  WriteLn (forward)
end;

begin
  forward := 'OK';
  Foo
end.
