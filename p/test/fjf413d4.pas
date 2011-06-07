program fjf413d4;

var
  a : array [^a .. ^b] of Char = 'OK';
  Foo : array [1 .. 2] of Char absolute a [^A];

begin
  WriteLn (Foo)
end.
