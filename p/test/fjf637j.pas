program fjf637j;

type
  a = abstract object
    procedure foo; abstract;
    procedure bar; abstract;
  end;

  b = object (a)
    procedure foo; virtual;
  end;

  c = object (a)
    procedure bar; virtual;
  end;

procedure b.foo;
begin
end;

procedure c.bar;
begin
end;

var
  v: c;  { WRONG }

begin
  WriteLn ('failed')
end.
