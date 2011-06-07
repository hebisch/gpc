program fjf639x3;

type
  pt = ^t;
  t = object
    procedure a;
  end;

  pu = ^u;
  u = object (t)
    procedure b;
  end;

procedure t.a;
begin
  Write ('O')
end;

procedure u.b;
begin
  WriteLn ('K')
end;

var
  v: pt;

begin
  v := New (pu);
  (v^ as u).a;
  (v^ as u).b
end.
