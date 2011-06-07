program adam3g;

type
  s = set of 1..10;

var
  v: s;

procedure at(const p: s);
begin
  v := p
end;

begin
  v := [2];
  at ([3]);
  if v = [3] then WriteLn ('OK') else WriteLn ('failed')
end.
