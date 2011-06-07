program fjf966d;

type
  u = set of 50 .. 60;
  t = set of 20 .. 80;

procedure a (v: t);
var i: Integer;
begin
  for i := 100 downto 0 do
    if i in v then Write (Succ ('H', i - 50));
  WriteLn
end;

begin
  a (u[53, 57])
end.
