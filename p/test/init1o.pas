program init1o(output);
type tvr = record i : integer; case 0..1 of
                    0 :(j : integer);
                    1 :(r : record c : char end)
           end;
var v : tvr value [i:1; case 2 of [j:1]]; { WRONG }
begin
  if v.j = 1 then writeln('failed')
end
.
