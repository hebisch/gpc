program fjf243;

type tstring=string(2048);

function foo:tstring;
begin
  foo:='OK'
end;

procedure bar (s:cstring);
begin
{$x+} writeln(s); {$x-}
end;

begin
  bar(foo)
end.
