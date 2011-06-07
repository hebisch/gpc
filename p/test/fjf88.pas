program fjf88;
const c = 7 shl (BitSizeOf (LongestCard) - 3);
var
  a:0..c;
  b:packed 0..c;
begin
 a:=0;
 b:=0;
 if (SizeOf(a)=SizeOf(LongestCard)) and (SizeOf(b)=SizeOf(LongestCard)) then writeln('OK') else writeln('Failed')
end.
