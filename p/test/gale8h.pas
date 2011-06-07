{$extended-pascal}
program gale8h (output);

type
  t = integer;

procedure foo(a : array[t..h : integer] of t);  {WRONG}
begin
end;

begin
writeln('FAIL');
end.

