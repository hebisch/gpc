program init2k(output);
{ FLAG -fextended-pascal }
type trr = record r: record i, j , k : integer end end;
var vr : trr;
begin
  vr := trr[r:(i:0; j:1; k:2)] { WRONG }
end
.
