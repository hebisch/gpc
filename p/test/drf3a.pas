program drf3a;
type
  xxx = integer attribute (Size = 6);
var
  x : set of xxx;
  c : xxx;
begin
  x := [1,2] >< [2,3];
  for c := Low (xxx) to High (xxx) do
    if (c in x) <> ((c = 1) or (c = 3)) then
      begin
        WriteLn ('failed ', c);
        Halt
      end;
  WriteLn ('OK')
end.
