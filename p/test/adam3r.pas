program adam3r;

var
  a, b, c: set of 1 .. 10;

procedure at(protected i: integer);
begin
  a := [2 .. i];
  b := [i .. 8];
  c := [i .. i]
end;

begin
  a := [];
  b := [];
  c := [];
  at (4);
  if (a = [2, 3, 4]) and (b = [4 .. 7, 8]) and (c = [4]) then WriteLn ('OK') else WriteLn ('failed')
end.
