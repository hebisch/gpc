program fjf413cb;

type
  c = array [1 .. 42] of Integer;
  TFoo = ^ c;

var
  Foo : TFoo;

begin
  if SizeOf (Foo^) = SizeOf (c)
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
