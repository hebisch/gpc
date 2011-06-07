program inipak1m(output);
type pa = packed record i, j : integer; a : packed array [1..5] of 0..7; end;

function paref3(const a : pa): integer;
begin
  paref3 := a.a[3]
end;
var v : pa;
begin
  v := pa[i, j: 0; a:[1..5:4]];
  if paref3(v) = 4 then writeln('OK')
end
.
