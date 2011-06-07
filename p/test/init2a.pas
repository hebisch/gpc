program init2a(output);
{ FLAG -fextended-pascal }
type ta = array [0..2] of integer;
var va : ta value [0; 1; 2]; { WRONG }
begin
end
.
