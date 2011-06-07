{$extended-pascal}
program gale8g (output);

type
  t = integer;

procedure foo(t: t); forward; {WRONG}

procedure foo;
begin
end;

begin
writeln('FAIL');
end.

