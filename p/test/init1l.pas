program init1l(output);
type tr = record i, j : integer end;
var a : tr value [i:1; case 0 of [j:1]]; { WRONG }
begin
  if a.i = 1 then writeln('failed')
end
.
