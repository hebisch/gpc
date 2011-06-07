{$object-pascal}
program gale8n (output);

type
  t = integer;
  c = class
    destructor foo(t: t);  {WRONG}
  end;

destructor c.foo;
begin
end;

begin
writeln('FAIL');
end.

