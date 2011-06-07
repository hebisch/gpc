program init1p(output);
type tvr = record i : integer; case 0..1 of
                    0 :(j : integer);
                    otherwise (r : record c : char end)
           end;
var v : tvr value [i:1; case 2 of [r:[c:'1']]]; { WRONG }
begin
  if v.r.c = '1' then writeln('failed')
end
.
