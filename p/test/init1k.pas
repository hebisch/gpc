program init1k(output);
type tr = record i, j : integer end;
var a : tr value [i:1; otherwise 1]; { WRONG }
begin
  if a.i = 1 then writeln('failed')
end
.
