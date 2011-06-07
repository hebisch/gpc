{$extended-pascal}
program gale8b (output);

type
  t = integer;

procedure foo(char: char);  {WRONG}
begin
end;

begin
writeln('FAIL');
end.

