program init1w(output);
type tvr(s : integer) = record i : integer; case s of
                    0..10:    (j : integer);
                    otherwise (r : record c : char end)
           end;
var v : tvr(12) value [i:1; case 8 of [j:3]]; { WRONG }
begin
  if v.i = 1 then writeln('failed')
end
.
