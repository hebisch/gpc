program fjf592c;

type
  TFoo = -1 .. MaxInt;

  Foo = record
    a: Integer
  end;

  Qux = record
    a: Integer
  end;

procedure Bar (var a: array [m .. n: TFoo] of Foo); forward;

procedure Bar (var a: array [m .. n: TFoo] of Qux);  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
