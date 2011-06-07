program sett;
  type ot = 0..1;
       st1 = set of ot;
       st2 = packed set of ot;
var s1 : st1;
    s2 : st2;
begin
  s1 := s2 { WRONG }
end
.
