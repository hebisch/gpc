{$extended-pascal}
program gale8c (output);

type
  t = integer;

function foo(t: t) : integer;  {WRONG}
begin
  foo := 0
end;

begin
writeln('FAIL');
end.

