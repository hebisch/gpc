{$W no-implicit-abstract}

program fjf637aa;

type
  t = object
    procedure f; abstract;
    procedure g;
  end;

procedure t.g;
begin
  f
end;

type
  u = object (t)
    constructor a;
    procedure f; virtual;
  end;

constructor u.a;
begin
end;

procedure u.f;
begin
  WriteLn ('OK')
end;

var
  v: u;

begin
  v.g
end.
