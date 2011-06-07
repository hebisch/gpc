program fjf972f(output);
type tr = record i,j: record k:integer end
          end;
var a : tr value [i,j:[k:1]];
begin
  if (a.i.k = 1) and (a.j.k = 1) then WriteLn ('OK') else WriteLn ('failed')
end
.
