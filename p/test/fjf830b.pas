program fjf830b;

var
  foo: Integer;  { WRONG }

label foo;

begin
  goto foo;
  foo:
end.
