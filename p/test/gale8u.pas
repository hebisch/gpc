program gale8u (output);

type
  t = integer;
  c = object
    procedure foo(t: t);  { WARN }
  end;

procedure c.foo;
begin
end;

begin
writeln('FAIL');
end.

