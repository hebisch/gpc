program fjf826c;

type
  t = object
    procedure p; attribute (name = 'foo');
  end;

procedure t.p;
begin
  WriteLn ('OK')
end;

procedure Foo (var Self: t); external name 'foo';

begin
  Foo (Null)
end.
