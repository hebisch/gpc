program init2f(output);
{ FLAG -fextended-pascal }
type ta = array [0..2] of integer;
var va : ta;
begin
  va := ta[0; 1; 2]; { WRONG }
end
.
