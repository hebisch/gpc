program fjf1016f;

type
  i2 = Integer value 2;
  i3 = Integer value 3;

  a = object
    b: i2;
    c: Integer value 4
  end;

  b = object (a)
    d: i3
  end;

var
  va: a;
  vb: b;

begin
  if (va.b = 2) and (va.c = 4) and (vb.b = 2) and (vb.c = 4) and (vb.d = 3) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
