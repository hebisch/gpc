program Foo;

type
  foo = object
    a : Integer;
    procedure bar (a : Integer);  { WRONG }
  end;

var
  f : foo;

procedure foo.bar (a : Integer);
begin
  a := 42
end;

begin
  WriteLn ('failed')
end.
