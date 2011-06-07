program fjf1063t;

type
  Foo = record end;
  Operator = (a, b: Foo) c: Foo;
begin
  c := a
end;

begin
  WriteLn ('OK')
end.
