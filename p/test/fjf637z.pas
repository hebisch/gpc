{$W no-implicit-abstract}

program fjf637z;

type
  t = object
    procedure f; abstract;
  end;

  u = abstract object (t)
    procedure f; virtual;
  end;

  v = object (u)
    constructor a;
  end;

procedure u.f;
begin
end;

constructor v.a;
begin
end;

var
  a: v;

begin
  WriteLn ('OK')
end.
