program fjf639x2;

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
  with v^ as u do
    begin
      a;
      b
    end
end.
