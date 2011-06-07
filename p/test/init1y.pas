program init1y(output);
type tvr(s : integer) = record i : integer; case s of
                    0..10:  (j : integer);
           end;
var v : tvr(22) value [i:1; case 7 of [j:3]]; { WRONG }
begin
  if v.i = 1 then writeln('failed')
end
.
