program fjf197;

{ FLAG -Werror }

type t=string(42);

procedure p(var v:t);
begin
  v:='OK'
end;

function ok=foo:t;
begin
  p(foo)
end;

begin
  writeln(ok)
end.
