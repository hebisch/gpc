{ FLAG -Werror }
program fjf282;

{$ignore-function-results}

type tstring = string (3);

function s:tstring;
begin
  writeln ('OK');
  s := 'foo'
end;

begin
  s
end.
