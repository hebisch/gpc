program inipak1r(output);
type pa = packed array [1..5] of 0..7;

function paref3(const a : pa): integer;
begin
  paref3 := a[3]
end;
var i : integer;
begin
  i := 4;
  if paref3(pa[1..5:i]) = 4 then writeln('OK')
end
.
