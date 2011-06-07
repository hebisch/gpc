program fjf565b;

function foo: Integer;
var foo: Integer;  { WRONG }
begin
  foo := 42;
  Return foo
end;

begin
  WriteLn ('failed')
end.
