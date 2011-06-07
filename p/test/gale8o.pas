{$extended-pascal}
program gale8 (output);

type
  t = integer;

procedure foo(procedure p(t : t));  {WRONG}
begin
end;

begin
writeln('FAIL');
end.

