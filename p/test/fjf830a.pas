program fjf830a;

label foo;

var
  foo: Integer;  { WRONG }

begin
  goto foo;
  foo:
end.
