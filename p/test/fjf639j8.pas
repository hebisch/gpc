program fjf639j8;

type
  t = abstract object procedure a; virtual end;
  u = abstract object (t) procedure b; virtual end;
  pv = ^v; v = object (t) constructor i; procedure c; virtual end;
  pw = ^w; w = object (u) constructor i; procedure d; virtual end;

procedure t.a; begin end;
procedure u.b; begin end;
constructor v.i; begin end;
procedure v.c; begin end;
constructor w.i; begin end;
procedure w.d; begin end;

var
  x: ^t;

begin
  x := New (pw);
  with x^ as u do
    d  { WRONG }
end.
