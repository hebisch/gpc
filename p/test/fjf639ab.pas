program fjf639ab;

type
  pt = ^t;
  t = object
    d: Char;
    procedure a;
  end;

  pu = ^u;
  u = object (t)
    procedure b;
  end;

  pv = ^v;
  v = object (u)
    procedure c;
  end;

procedure t.a;
begin
  Write ('O');
  d := 'J'
end;

procedure u.b;
begin
  Inc (d)
end;

procedure v.c;
begin
  WriteLn (d)
end;

var
  z: pt;

begin
  z := New (pv);
  z^.a;
  (z^ as u).b;
  (z^ as u as v).c
end.
