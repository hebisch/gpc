program rrr(Output);
type tr = (a);
     tp = packed array [1 .. 1] of tr;
begin
  if bitsizeof(tp) <= bitsizeof(longestint) then WriteLn ('OK') else WriteLn ('failed')
end
.
