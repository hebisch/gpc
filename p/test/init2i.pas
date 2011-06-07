program init2i(output);
type tr = record i, j , k : integer end;
var vr : tr;
begin
  vr := tr(i:0; j:1; k:2); { WRONG }
end
.
