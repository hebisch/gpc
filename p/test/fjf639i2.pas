program fjf639i2;

type
  t = abstract object end;
  u = abstract object (t) end;
  pv = ^v; v = object (t) end;
  pw = ^w; w = object (u) end;

var
  x: ^t;

begin
  x := New (pw);
  if x^ is u then WriteLn ('OK') else WriteLn ('failed')
end.
