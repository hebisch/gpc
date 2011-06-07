program fjf592a;

type
  TFoo = -1 .. MaxInt;

  Foo = record
    a: Integer
  end;

procedure Bar (var a: array [m .. n: TFoo] of Foo); forward;

procedure Bar (var a: array [m .. n: TFoo] of Foo);
begin
  WriteLn (Chr (n), Chr (m))
end;

const
  o = Ord ('O');
  k = Ord ('K');

var
  b: array [k .. o] of Foo;

begin
  Bar (b)
end.
