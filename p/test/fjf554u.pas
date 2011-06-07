program fjf554u;

type
  x = set of Byte;

function foo (a: Integer): x;
begin
  foo := []
end;

begin
  foo (42) := [];  { WRONG }
  WriteLn ('failed')
end.
