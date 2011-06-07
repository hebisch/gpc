program fjf210;

type foo = string(2);

procedure bar;

function OK : foo;
begin
  OK := 'OK'
end;

var c:foo=OK;

begin
  writeln(c)
end;

begin
  bar
end.
