program rrr(Output);
type tr = (a);
     tp = packed record
            i : tr;
          end;
begin
  if bitsizeof(tp) <= bitsizeof(longestint) then WriteLn ('OK') else WriteLn ('failed')
end
.
