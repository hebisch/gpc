program init2h(output);
type ta = array [0..2] of integer;
var va : ta;
begin
  va := ta(0:0; 1:1; 2:2); { WRONG }
end
.
