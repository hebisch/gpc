{$extended-pascal}
program gale8e (output);

type
  t = integer;

procedure foo(i: t; procedure t);  {WRONG}
begin
end;

begin
writeln('FAIL');
end.

