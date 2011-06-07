program fjf939c;

type
  a = procedure (b: array of Char);

var
  v: a;

procedure c (b: array of Char);
var i: Integer;
begin
  for i := Low (b) to High (b) do Write (b[i]);
  WriteLn
end;

begin
  v := c;
  v ('OK')
end.
