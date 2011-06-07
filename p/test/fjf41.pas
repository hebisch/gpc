program fjf41;
const c = 7 shl (BitSizeOf (LongestCard) - 3);
var a:0..c;
begin
 a:=0;
 if SizeOf(a) < SizeOf (LongestCard) then
   writeln ( 'failed: ', SizeOf ( a ) )
 else
   writeln ( 'OK' );
end.
