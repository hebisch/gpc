{$extended-pascal}
program gale8 (output);

type
  t = integer;

procedure foo(function p(t : t):integer);  {WRONG}
begin
end;

begin
writeln('FAIL');
end.

