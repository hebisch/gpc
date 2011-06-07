program init2(output);
{ FLAG -fextended-pascal }
type trc = 0..2;
     trr = record case trc of
             0:( i: integer);
             1:( j: integer);
             2:( k: integer)
           end;
var vr : trr;
begin
  vr := trr[i:0] { WRONG }
end
.
