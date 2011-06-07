program init2g(output);
{ FLAG -fextended-pascal }
type tr = record i, j , k : integer end;
var vr : tr;
begin
  vr := tr[0; 1; 2]; { WRONG }
end
.
