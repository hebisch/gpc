program inipak1c(output);
type pa = packed array [1..5] of 0..7;
const c = pa[1..5:4];
function paref3(const a : pa): integer;
begin
  paref3 := a[3]
end;
begin
  if paref3(c) = 4 then writeln('OK')
end
.
