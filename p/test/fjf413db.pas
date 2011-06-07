program fjf413db;

type
  c = array [1 .. 42] of Integer;

var
  Foo : record
    x : (^a) .. (^b);
    y : ^c;
  end;

begin
  if (Low (Foo.x) = #1) and (High (Foo.x) = ^B) and (SizeOf (Foo.y^) = SizeOf (c))
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
