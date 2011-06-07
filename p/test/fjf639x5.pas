program fjf639x5;

type
  pt = ^t;
  t = object
    constructor i;
    procedure a; virtual;
  end;

  pu = ^u;
  u = object (t)
    procedure b; virtual;
  end;

constructor t.i;
begin
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
