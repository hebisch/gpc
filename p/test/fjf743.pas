program fjf743;

function f: Integer;
begin
  f := 3
end;

begin
  if Chr (f and 6) = #2 then WriteLn ('OK') else WriteLn ('failed')
end.
