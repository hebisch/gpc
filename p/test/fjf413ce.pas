program fjf413ce;

type
  c = array [1 .. 42] of Integer;
  TFoo = object
    x : (^a) .. (^b);
    y : ^c;
  end;

var
  Foo : TFoo;

begin
  if (Low (Foo.x) = #1) and (High (Foo.x) = ^B) and (SizeOf (Foo.y^) = SizeOf (c))
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
