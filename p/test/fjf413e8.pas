program fjf413e8;

var
  a : array [Boolean] of Char = 'OK';

begin
  var Foo : array [1 .. 2] of Char absolute a [True = False];
  WriteLn (Foo)
end.
