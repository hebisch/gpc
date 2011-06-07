program inipak1j(output);
type pa = record i, j : integer; a : packed array [1..5] of 0..7; end;

function paref3(const a : pa): integer;
begin
  paref3 := a.a[3]
end;
begin
  if paref3(pa[i, j: 0; a:[1..5:4]]) = 4 then writeln('OK')
end
.
