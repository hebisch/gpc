program fjf84a;
const c = 1 shl (BitSizeOf (LongestInt) - 1);
var x:LongestInt=c;
begin { WRONG }
  writeln('Failed: ', c)
end.
