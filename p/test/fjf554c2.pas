program fjf554c2;

type
  x = set of Byte;

function foo: x;
begin
  foo := []
end;

begin
  if [] * foo = [] then WriteLn ('failed') else WriteLn ('failed 2')  { WARN }
end.
