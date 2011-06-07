program fjf413d8;

var
  a : array [Boolean] of Char = 'OK';
  Foo : array [1 .. 2] of Char absolute a [True = False];

begin
  WriteLn (Foo)
end.
