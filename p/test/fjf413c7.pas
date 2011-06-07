program fjf413c7;

type
  TFoo = Boolean value True = False;

var
  Foo : TFoo;

begin
  if Foo = False then WriteLn ('OK') else WriteLn ('failed')
end.
