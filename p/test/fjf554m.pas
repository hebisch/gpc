program fjf554m;

type
  x = set of Byte;

function foo: x;
begin
  foo := []
end;

begin
  if not {$W-} ([] > foo) then {$W+} WriteLn ('OK') else WriteLn ('failed')
end.
