program fjf554s;

type
  x = set of Byte;

function foo: x;
begin
  foo := []
end;

begin
  WriteLn ('failed ', [] > foo)  { WARN }
end.
