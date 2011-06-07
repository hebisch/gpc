program fjf781m;

const
  Qux = 'ba';

var
  VBaz: String (2) = 'OK'; attribute (name ('vbar'));

procedure Baz (const s: String); attribute (name ('bar')); forward;
procedure Baz (const s: String);
begin
  WriteLn ('OK')
end;

var
  VFoo: String (2); external; attribute (name ('v' + Qux + 'r'));

procedure Foo (const s: String); external; attribute (name ('ba' 'r'));

begin
  Foo (VFoo)
end.
