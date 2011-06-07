program fjf413ea;

var
  a : array [(^a) .. (^b)] of Char = 'OK';

begin
  var Foo : array [1 .. 2] of Char absolute a [(^A)];
  WriteLn (Foo)
end.
