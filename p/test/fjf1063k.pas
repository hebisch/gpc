program fjf1063k;

type
  s = String (10);
  t = object
    Constructor Init;
    Destructor Done;
  end;

const
  Foo = 42;

Operator * (a, b: Char) = c: s;
begin
  c := a + b
end;

const
  Bar = 17;

Constructor t.Init;
begin
end;

const
  Baz = 99;

Destructor t.Done;
begin
end;

begin
  WriteLn ('O' * 'K')
end.
