program fjf456;

type
  Int16 = Integer attribute (Size = 16);
  r = record
    a, b : Int16
  end;

  s (d : Integer) = record
    f : r
  end;

var
  v : s (1);
  w : r = (0, 0);

begin
  v.f.a := Ord ('O');
  v.f.b := Ord ('K');
  w := v.f;
  WriteLn (Chr (w.a), Chr (w.b))
end.
