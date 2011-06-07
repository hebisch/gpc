{$extended-pascal}
program gale8f (output);

type
  t = integer;

procedure foo(function t: t);  {WRONG}
begin
end;

begin
writeln('FAIL');
end.

