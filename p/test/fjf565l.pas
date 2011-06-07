program fjf565l;

function foo = bar: Integer;
var foo: Integer;  { This should be allowed I think }
begin
  foo := 42;
  bar := foo + 1
end;

begin
  if foo = 43 then WriteLn ('OK') else WriteLn ('failed')
end.
