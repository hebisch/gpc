program fjf640;

type
  t = foo;

var
  v: ^t;  { WRONG }

begin
  WriteLn ('failed')
end.
