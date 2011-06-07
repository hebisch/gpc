program fjf413cf;

var
  a : array [(^a) .. (^b)] of Char = 'OK';

type
  TFoo = array [1 .. 2] of Char;

var
  Foo : TFoo absolute a [(^A)];

begin
  WriteLn (Foo)
end.
