program fjf554v;

type
  x = set of Byte;

var
  y: x;

function foo (a: Integer): x;
begin
  foo := []
end;

begin
  foo (42) := y;  { WRONG }
  WriteLn ('failed')
end.
