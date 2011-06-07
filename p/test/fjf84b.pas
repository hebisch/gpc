program fjf84b;
const c = 1 shl (BitSizeOf (LongestInt) - 1);
var x:LongestInt=c div 2;
begin
  if x = 1 shl (BitSizeOf (LongestInt) - 2) then writeln ('OK') else writeln ('Failed ', x, ' ', 1 shl (BitSizeOf (LongestInt) - 2))
end.
