program sets17b(output);
type enu = (en1, en2, en3, en4);
var ok : boolean;
    ev : enu;
    se1, se2 : set of enu;

begin
  ok := true;
  se2 := [en3];

  if (se2 + ([4..6]*[3,5])) <> ([2..5] - [4]) then { WRONG }
    ok := false;

end
.  
