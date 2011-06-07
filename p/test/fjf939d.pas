program fjf939d;

var
  x: String (2);

type
  a = procedure (b: type of x);

var
  v: a;

procedure c (b: type of x);
begin
  WriteLn (b)
end;

begin
  v := c;
  v ('OK')
end.
