program fjf592e;

type
  Foo = record
    a: Integer
  end;

  Qux = record
    a: Integer
  end;

procedure Bar (var a: array of Foo); forward;

procedure Bar (var a: array of Qux);  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
