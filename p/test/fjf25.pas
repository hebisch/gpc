program fjf25;
type card64 = cardinal attribute (Size = 64);
var y:packed record z:card64; end;
begin
 y.z:=0;
 writeln ( 'OK' );
end.
