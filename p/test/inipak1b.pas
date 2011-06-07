program inipak1b(output);
type pa = packed array [1..5] of 0..7;

function paref3(const a : pa): integer;
begin
  paref3 := a[3]
end;
var va : pa;
begin
  va := pa[1..5:4];
  if paref3(va) = 4 then writeln('OK')
end
.
