{$object-pascal}
program gale8l (output);

type
  t = integer;
  c = class
    function foo(t: t) : integer;  {WRONG}
  end;

function c.foo;
begin
  foo := 0
end;

begin
writeln('FAIL');
end.

