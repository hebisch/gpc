program fjf662a;

type
  o = object
    a: String (2);
    procedure Foo (procedure Bar (const s: String));
  end;

procedure Baz (const s: String);
begin
  WriteLn (s)
end;

procedure o.Foo (procedure Bar (const s: String));
begin
  Bar (a)
end;

var
  v: o;

begin
  v.a := 'OK';
  v.Foo (Baz)
end.
