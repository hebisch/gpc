program adam3k;

var
  s: set of 1..10;

procedure at(const i: integer);
begin
  Include (s, i)
end;

begin
  s := [3];
  at (5);
  if s = [3, 5] then WriteLn ('OK') else WriteLn ('failed')
end.
