program fjf737a;

var
  c: Integer = 0;

function f: Byte;
begin
  Inc (c);
  f := 0
end;

begin
  if 1 in [f] then WriteLn ('failed 1');
  if c = 1 then WriteLn ('OK') else WriteLn ('failed')
end.
