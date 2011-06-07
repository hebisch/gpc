program init2j(output);
{ FLAG -fextended-pascal }
type tra = record r: array [0..2] of integer end;
var va : tra;
begin
  va := tra[r: (0:0; 1:1; 2:2)] { WRONG }
end
.
