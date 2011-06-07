program inipak1e(output);
type pa = packed array [1..5] of 0..7;

function paref3(const a : pa): integer;
begin
  paref3 := a[3]
end;
procedure p;
var va : pa value pa[1..5:4];
begin
  if paref3(va) = 4 then writeln('OK')
end;
begin
  p
end
.
