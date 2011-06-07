program inipak1v(output);
type pa = record ca: array[1..7] of char;
                        a: packed array [1..5] of 0..7;
          end;

function paref3(const a : pa): integer;
begin
  paref3 := a.a[3]
end;
var i : integer;
begin
  i := 4;
  if paref3(pa[ca: [1..7 : ' ']; a : [1..5:i]]) = 4 then writeln('OK')
end
.
