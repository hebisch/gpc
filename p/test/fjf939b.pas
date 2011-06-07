program fjf939b;

type
  a = procedure (b: array [e .. f: Integer] of Char);

var
  v: a;

procedure c (b: array [e .. f: Integer] of Char);
var i: Integer;
begin
  for i := e to f do Write (b[i]);
  WriteLn
end;

begin
  v := c;
  v ('OK')
end.
