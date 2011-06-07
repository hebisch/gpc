program fjf1063m;

type
  s = String (10);
  t = object
    Constructor Init;
    Destructor Done;
  end;

type
  Foo = Integer;

Operator * (a, b: Char) = c: s;
begin
  c := a + b
end;

type
  Bar = Real;

Constructor t.Init;
begin
end;

type
  Baz = Char;

Destructor t.Done;
begin
end;

begin
  WriteLn ('O' * 'K')
end.
