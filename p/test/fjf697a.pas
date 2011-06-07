program fjf697a;

type
  foo = ^const Integer;

var
  a: foo;

begin
  New (a);
  a^ := 42;  { WRONG }
  WriteLn ('failed')
end.
