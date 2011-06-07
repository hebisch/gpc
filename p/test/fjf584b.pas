program fjf584b;

type
  Foo = ^Foo;
  Bar = ^Bar;

var
  x: Foo;
  y: Bar;

begin
  x := y;  { WRONG }
  WriteLn ('failed')
end.
