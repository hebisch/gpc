program fjf554c;

type
  x = set of Byte;

function foo: x;
begin
  foo := []
end;

{$W-}

begin
  if [] * foo = [] then WriteLn ('OK') else WriteLn ('failed')
end.
