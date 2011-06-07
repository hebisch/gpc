program fjf766;

function f = r: Integer;
var p: ^Integer;
begin
  p := @r;
  p^ := 42
end;

begin
  if f = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
