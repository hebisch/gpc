program adam3m;

var
  s: set of 1..10;

procedure at(const i: integer);
begin
  Exclude (s, i)
end;

begin
  s := [3 .. 6];
  at (4);
  if s = [3, 5, 6] then WriteLn ('OK') else WriteLn ('failed')
end.
