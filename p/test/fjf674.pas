program fjf674;

type
  o = object
    constructor Foo;
  end;

constructor o.Foo;
begin
end;

var
  p: ^o;

begin
  WriteLn ('failed');
  Halt;
  Dispose (p, Foo)  { WRONG }
end.
