program fjf554x;

type
  x = set of Byte;

function foo: x;
begin
  x := []  { WRONG }
end;

begin
  WriteLn ('failed')
end.
