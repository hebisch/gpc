program fjf747;

function f: Byte; attribute (const);
begin
  f:=1
end;

begin
 if [f] = [1] then WriteLn ('OK') else WriteLn ('failed')
end.
