program init1h(output);
type tr = record i: integer; j:boolean end;
var a : tr value [i,j:1]; { WRONG }
begin
  if a.i = 1 then writeln('failed')
end
.
