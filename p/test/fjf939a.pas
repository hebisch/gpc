program fjf939a;

type
  a = procedure (procedure b);

var
  v: a;

procedure b;
begin
  WriteLn ('K')
end;

procedure c (procedure d);
begin
  Write ('O');
  d
end;

begin
  v := c;
  v (b)
end.
