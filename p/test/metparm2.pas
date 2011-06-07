program Foo;

type
  foo = object
    function a : Integer;
    procedure bar (a : Integer); { WRONG }
  end;

var
  f : foo;

function foo.a : Integer;
begin
  a := 12
end;

procedure foo.bar (a : Integer);
begin
end;

begin
  WriteLn ('failed')
end.
