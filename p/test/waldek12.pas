program newerr(output);
type vr = record case boolean of
            false :(j : integer);
            true :(r : record c : char end)
          end;
var pvr : ^vr;
begin
  new(pvr, 1) { WRONG }
end
.
