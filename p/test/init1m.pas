program init1m(output);
type tvr = record i : integer; case boolean of
                    false :(j : integer);
                    true :(r : record c : char end)
           end;
var v : tvr value [i:1; case 0 of [j:1]]; { WRONG }
begin
  if v.j = 1 then writeln('failed')
end
.
