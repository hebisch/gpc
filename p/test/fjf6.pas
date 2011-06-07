program fjf6;

type
  ts=set of byte;

procedure p(s:ts);
var k:integer;
begin
  for k:=0 to $ff do
    if k in s then write(k)
end;

begin
  p([]);
  writeln ( 'OK' );
end.
