program fjf413c1;

type
  TFoo = array [1 .. 3] of Char = ^B^A^R;

var
  Foo : TFoo;

begin
  if Foo = ^B^A^R then WriteLn ('OK') else WriteLn ('failed')
end.
