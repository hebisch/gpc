program fjf781k;

const
  Qux = 'ba';

var
  VBaz: String (2) = 'OK'; attribute (name = 'vbar');

procedure Baz (const s: String); attribute (name = 'bar'); forward;
procedure Baz (const s: String);
begin
  WriteLn ('OK')
end;

var
  VFoo: String (2); external name 'v' + Qux + 'r';

procedure Foo (const s: String); external name 'ba' 'r';

begin
  Foo (VFoo)
end.
