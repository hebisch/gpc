program fjf413c8;

var
  a : array [Boolean] of Char = 'OK';

type
  TFoo = array [1 .. 2] of Char;

var
  Foo : TFoo absolute a [True = False];

begin
  WriteLn (Foo)
end.
