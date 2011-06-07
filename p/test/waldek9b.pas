program rrr(Output);
type tr = record end;
     tp = packed record
            i : tr;
          end;
var a : array [0..15] of tp;
    pa : packed array [0..15] of tp;
begin
  pack (a, 0, pa);
  WriteLn ('OK')
end
.
