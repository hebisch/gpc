program fjf554i;

type
  x = set of Byte;

var
  Called: Boolean = False;

function foo: x;
begin
  Called := True;
  foo := []
end;

begin
  if not (foo > []) and Called then WriteLn ('OK') else WriteLn ('failed')
end.
