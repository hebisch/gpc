program fjf355a;
const c = 7 shl (BitSizeOf (LongestCard) - 3);
var
  a:-1..c;  { WRONG }
begin
  writeln ('failed: ', low (a), '..', high (a))
end.
