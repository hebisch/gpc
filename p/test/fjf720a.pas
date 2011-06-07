program fjf720a;

type
  foo = object
    procedure bar;
  end;

procedure foo.bar;
begin
end;

procedure baz (procedure foo.bar);  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
