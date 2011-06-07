program fjf355;
const c = 7 shl (BitSizeOf (LongestCard) - 3);
var
  a:0..c;
  s,cs:string (100);
begin
 a:=c;
 writestr(s,a);
 writestr(cs,c);
 if s <> cs then
   writeln ( 'failed: ', s, ' ', cs)
 else
   writeln ( 'OK' );
end.
