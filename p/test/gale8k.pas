{$object-pascal}
program gale8k (output);

type
  t = integer;
  c = class
    procedure foo(t: t);  {WRONG}
  end;

procedure c.foo;
begin
end;

begin
writeln('FAIL');
end.

