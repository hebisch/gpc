program fjf33;
var x:-2147483649..2147483649;
begin
 if sizeof(x) > 4 then
   writeln ( 'OK' )
 else
   writeln ( 'failed' );
end.
