program fjf554t;

type
  x = set of Byte;

function foo: x;
begin
  foo := [2]
end;

begin
  if foo + [1] = [1, 2] then WriteLn ('OK') else WriteLn ('failed')
end.
