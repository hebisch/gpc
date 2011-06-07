program proc2b;
function zero:integer;
begin
  zero := 0
end;
type fs(i:integer) = function : integer;
var fv : fs(1) value zero;
begin
  if fv = 0 then WriteLn ('OK') else WriteLn ('failed')
end
.
