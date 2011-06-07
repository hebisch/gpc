program fjf413e1;

begin
  var Foo : array [1 .. 3] of Char = ^B^A^R;
  if Foo = ^B^A^R then WriteLn ('OK') else WriteLn ('failed')
end.
