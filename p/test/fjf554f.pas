program fjf554f;

type
  x = set of Byte;

function foo: x;
begin
  foo := []
end;

begin
  if {$W-} (foo >= []) then {$W+} WriteLn ('OK') else WriteLn ('failed')
end.
