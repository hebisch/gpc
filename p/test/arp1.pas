program p;
const c = (BitSizeOf (integer) + 4) div 3;
var n : integer;
begin
   {GPC does not detect the overflow, why?}
   n := 10 pow c  { WRONG }
end.
