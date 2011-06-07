program fjf413eb;

type
  c = array [1 .. 42] of Integer;

begin
  var
    Foo : record
      x : (^a) .. (^b);
      y : ^c;
    end;
  if (Low (Foo.x) = #1) and (High (Foo.x) = (^B)) and (SizeOf (Foo.y^) = SizeOf (c))
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
