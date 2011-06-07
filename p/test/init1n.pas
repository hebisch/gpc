program init1n(output);
type tvr = record i : boolean; case boolean of
                    false :(j : integer);
                    true :(r : record c : char end)
           end;
var v : tvr value [i:true; case i:false of [j:1]]; { WRONG }
begin
  if v.j = 1 then writeln('failed')
end
.
