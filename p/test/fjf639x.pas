program fjf639x;

type
  pt = ^t;
  t = object
    a: Integer
  end;

  pu = ^u;
  u = object (t)
    b: Integer
  end;

var
  v: pt;

begin
  v := New (pu);
  with v^ as u do
    begin
      a := 42;
      b := 17
    end;
  WriteLn ('OK')
end.
