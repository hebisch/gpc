{$extended-pascal}
program gale8a (output);

type
  t = integer;

procedure foo(t: t);  {WRONG}
begin
end;

begin
writeln('FAIL');
end.

