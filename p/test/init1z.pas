program init1z(output);
type tvr(s : integer) = record i : integer; case s of
                    0..10:  (j : integer);
           end;
var v : tvr(7) value [i:1; case 22 of [j:3]]; { WRONG }
begin
  if v.i = 1 then writeln('failed')
end
.

