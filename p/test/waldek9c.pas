program rrr(Output);
type tp = array [1 .. 10] of Integer;
var a : array [0..15] of tp;
    pa : packed array [0..15] of tp;
begin
  pack (a, 0, pa);
  WriteLn ('OK')
end
.
