program fjf413b2;

const
  Foo : array [1 .. 3] of Char = ^B^A^R;

begin
  if Foo = ^B^A^R then WriteLn ('OK') else WriteLn ('failed')
end.
