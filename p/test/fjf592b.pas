program fjf592b;

type
  TFoo = -1 .. MaxInt;

  Foo = record
    a: Integer
  end;

procedure Bar (var a: array [m .. n: TFoo] of Foo); forward;

procedure Bar (var a: array [m .. n: Integer] of Foo);  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
