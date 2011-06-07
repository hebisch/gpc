program fjf718a;

type
  t = object
    constructor Init;
  end;

constructor t.Init;

  procedure Foo;
  begin
    Fail  { WRONG, according to BP }
  end;

begin
  Foo
end;

begin
  WriteLn ('failed')
end.
