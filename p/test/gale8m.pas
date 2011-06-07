{$object-pascal}
program gale8m (output);

type
  t = integer;
  c = class
    constructor foo(t: t);  {WRONG}
  end;

constructor c.foo;
begin
end;

begin
writeln('FAIL');
end.

