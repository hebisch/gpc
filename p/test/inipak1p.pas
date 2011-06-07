program inipak1p(output);
type pa = packed array [1..5] of packed array [1..5] of 0..7;

function paref3(const a : pa): integer;
begin
  paref3 := a[3][3]
end;
begin
  if paref3(pa[otherwise [1..5:4]]) = 4 then writeln('OK')
end
.
