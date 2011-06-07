program init1i(output);
type tr = record i: record k:integer end;
                 j: record k:integer end
          end;
var a : tr value [i,j:[k:1]]; { WRONG }
begin
  if a.i.k = 1 then writeln('failed')
end
.
