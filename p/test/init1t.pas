program init1t(output);
type tvr(s : boolean) = record i : integer; case s of
                    false :(j : integer);
                    true :(r : record c : char end)
           end;
var v : tvr(true) value [i:1; case false of [j:1]]; { WRONG }
begin
  if v.i = 1 then writeln('failed')
end
.
