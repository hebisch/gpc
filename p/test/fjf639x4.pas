program fjf639x4;

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
  with v^ as u do
    begin
      a;
      b
    end
end.
