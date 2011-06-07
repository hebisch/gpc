program fjf639z2;

type
  pt = ^t;
  t = object
    f: Char;
    procedure a;
  end;

  pu = ^u;
  u = object (t)
    g: Char;
    procedure b;
  end;

procedure t.a;
begin
  Write (f)
end;

procedure u.b;
begin
  WriteLn (g)
end;

var
  v: pt;
  w: pu;

begin
  New (w);
  w^.f := 'O';
  w^.g := 'K';
  v := w;
  with v^ as u do
    begin
      a;
      b
    end
end.
