{ global variables initialized by a function don't work (fjf210b.pas) }

program fjf210b;

type foo = string(2);

function OK : foo;
begin
  OK := 'OK'
end;

var c:foo=OK;

begin
  writeln(c);
end.
