program fjf413c5;

type
  TFoo = Boolean = True = False;

var
  Foo : TFoo;

begin
  if Foo = False then WriteLn ('OK') else WriteLn ('failed')
end.
