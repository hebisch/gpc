program inipak1o(output);
type pa = array [1..5] of packed array [1..5] of 0..7;

function paref3(const a : pa): integer;
begin
  paref3 := a[3][3]
end;
var v : pa;
begin
  v := pa[otherwise [1..5:4]];
  if paref3(v) = 4 then writeln('OK')
end
.
