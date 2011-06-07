program fjf781g;

var
  VBaz: String (2) = 'OK'; attribute (name = 'vbar');

procedure Baz (const s: String); attribute (name = 'bar'); forward;
procedure Baz (const s: String);
begin
  WriteLn ('OK')
end;

var
  VFoo: String (2); external; attribute (name = 'vbar');

procedure Foo (const s: String); external; attribute (name = 'bar');

begin
  Foo (VFoo)
end.
