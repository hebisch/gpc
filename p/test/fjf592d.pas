program fjf592d;

type
  Foo = record
    a: Integer
  end;

procedure Bar (var a: array of Foo); forward;

procedure Bar (var a: array of Foo);
begin
  WriteLn (Succ ('K', High (a)), 'K')
end;

const
  o = Ord ('O') + 42;
  k = Ord ('K') + 42;

var
  b: array [k .. o] of Foo;

begin
  Bar (b)
end.
