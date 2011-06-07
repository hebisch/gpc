{$extended-pascal}
program gale8q (output);

type
  t = integer;

procedure foo(function p(t : integer) = t : integer);  {WRONG}
begin
end;

begin
writeln('FAIL');
end.

