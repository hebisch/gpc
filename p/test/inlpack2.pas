program inlpack2;
type pa = record a : packed array [1..5] of 0..7; end;

function paref3(const a : pa): integer;
begin
  paref3 := a.a[3]
end;
begin
  if paref3(pa[a:[1..5:4]]) = 4 then
    writeln('OK')
  else
    writeln('failed')
end
.
