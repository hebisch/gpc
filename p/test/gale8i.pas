{$extended-pascal}
program gale8i (output);

type
  t = integer;

procedure foo(a : array[t..h : t] of integer);  {WRONG}
begin
end;

begin
writeln('FAIL');
end.

