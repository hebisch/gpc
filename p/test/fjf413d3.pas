program fjf413d3;

var
  Foo : array [1 .. 3] of Char value ^B^A^R;

begin
  if Foo = ^B^A^R then WriteLn ('OK') else WriteLn ('failed')
end.
