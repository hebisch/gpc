program drf3b;
type xxx = Char;
var
  x : set of xxx;
  c : xxx;
begin
  x := ['b', 'd'] >< ['d', 'e'];
  for c := Low (xxx) to High (xxx) do
    if (c in x) <> ((c = 'b') or (c = 'e')) then
      begin
        WriteLn ('failed ', c);
        Halt
      end;
  WriteLn ('OK')
end.
