program fjf662b;

type
  p = procedure (const s: String);
  o = object
    a: String (2);
    procedure Foo (Bar: p);
  end;

procedure Baz (const s: String);
begin
  WriteLn (s)
end;

procedure o.Foo (Bar: p);
begin
  Bar (a)
end;

var
  v: o;

begin
  v.a := 'OK';
  v.Foo (Baz)
end.
