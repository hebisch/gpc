program fjf781l;

const
  Qux = 'ba';

var
  VBaz: String (2) = 'OK'; attribute (name = 'vbar');

procedure Baz (const s: String); attribute (name = 'bar');
begin
  WriteLn ('OK')
end;

var
  VFoo: String (2); external name 'v' + Qux + 'r';

procedure Foo (const s: String); external name 'ba' 'r';

begin
  Foo (VFoo)
end.
