program fjf637y;

type
  t = object
    procedure f; abstract;
  end;

  u = abstract object (t)
    procedure f; virtual;
  end;

  v = object (u)
    constructor i;
  end;

procedure u.f;
begin
end;

constructor v.i;
begin
end;

var
  a: u;  { WRONG }

begin
  WriteLn ('failed')
end.
