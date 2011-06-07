program fjf639i;

type
  t = abstract object end;
  u = abstract object (t) end;
  pv = ^v; v = object (t) end;
  pw = ^w; w = object (u) end;

var
  x: ^t;

begin
  x := New (pv);
  if not (x^ is u) then WriteLn ('OK') else WriteLn ('failed')
end.
