program drf3c;
type
  xxx = (d, e, f, g, h, i, j);
var
  x : set of xxx;
  c : xxx;
begin
  x := [i, g, h] >< [h, e, i];
  for c := Low (xxx) to High (xxx) do
    if (c in x) <> ((c = g) or (c = e)) then
      begin
        WriteLn ('failed ', Ord (c));
        Halt
      end;
  WriteLn ('OK')
end.
