program fjf697b;

type
  foo = ^const i;
  i = Integer;

var
  a: foo;

begin
  New (a);
  a^ := 42;  { WRONG }
  WriteLn ('failed')
end.
