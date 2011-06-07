program fjf1063i;

type
  s = String (10);
  t = object
    Constructor Init;
    Destructor Done;
  end;

var
  Foo: Integer;

Operator * (a, b: Char) = c: s;
begin
  c := a + b
end;

var
  Bar: Integer;

Constructor t.Init;
begin
end;

var
  Baz: Integer;

Destructor t.Done;
begin
end;

begin
  WriteLn ('O' * 'K')
end.
