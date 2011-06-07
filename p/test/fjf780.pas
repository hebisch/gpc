program fjf780;

var
  VBaz: String (2) = 'OK'; attribute (name = 'vbar');

procedure Baz (const s: String); attribute (name = 'bar'); forward;
procedure Baz (const s: String);
begin
  WriteLn ('OK')
end;

var
  VFoo: String (2); external name 'vbar';

procedure Foo (const s: String); external name 'bar';

begin
  Foo (VFoo)
end.
