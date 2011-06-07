{$extended-pascal}
program gale8d (output);

type
  t = integer;

function foo(i : t) = t : integer;  {WRONG}
begin
  t := 0
end;

begin
writeln('FAIL');
end.

