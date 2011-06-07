{$extended-pascal}
program gale8j (output);

type
  t = integer;

procedure foo(a : array[l..t : integer] of t);  {WRONG}
begin
end;

begin
writeln('FAIL');
end.

