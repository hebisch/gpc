program inipak1i(output);
type pa = packed record a : packed array [1..5] of 0..7; end;

function paref3(const a : pa): integer;
begin
  paref3 := a.a[3]
end;
var v : pa;
begin
  v := pa[a:[1..5:4]];
  if paref3(v) = 4 then writeln('OK')
end
.
