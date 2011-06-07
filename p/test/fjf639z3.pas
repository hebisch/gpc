program fjf639z3;

type
  pt = ^t;
  t = object
    f: Char;
    constructor i;
    procedure a; virtual;
  end;

  pu = ^u;
  u = object (t)
    g: Char;
    procedure b; virtual;
  end;

constructor t.i;
begin
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
