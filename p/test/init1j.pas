program init1j(output);
type tr = record i: integer; j:0..1 end;
var a : tr value [i,j:1]; { WRONG }
begin
  if a.i = 1 then writeln('failed')
end
.
