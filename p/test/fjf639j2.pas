program fjf639j2;

type
  t = abstract object a: Integer end;
  u = abstract object (t) b: Integer end;
  pv = ^v; v = object (t) c: Integer end;
  pw = ^w; w = object (u) d: Integer end;

var
  x: ^t;

begin
  x := New (pw);
  with x^ as u do
    WriteLn (d)  { WRONG }
end.
