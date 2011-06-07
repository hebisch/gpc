program fjf639j7;

type
  t = abstract object procedure a end;
  u = abstract object (t) procedure b end;
  pv = ^v; v = object (t) procedure c end;
  pw = ^w; w = object (u) procedure d end;

procedure t.a; begin Write ('O') end;
procedure u.b; begin WriteLn ('K') end;
procedure v.c; begin end;
procedure w.d; begin end;

var
  x: ^t;

begin
  x := New (pw);
  with x^ as u do
    begin
      a;
      b
    end
end.
