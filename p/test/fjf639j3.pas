program fjf639j3;

type
  t = abstract object a: Integer end;
  u = abstract object (t) b: Integer end;
  pv = ^v; v = object (t) c: Integer end;
  pw = ^w; w = object (u) d: Integer end;

var
  x: ^t;

begin
  x := New (pw);
  with x^ do
    WriteLn (b)  { WRONG }
end.
