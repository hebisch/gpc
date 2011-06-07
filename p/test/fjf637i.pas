program fjf637i;

type
  a = abstract object
    procedure foo; abstract;
    procedure bar; abstract;
  end;

  b = object (a)
    procedure foo; virtual;
  end;

  c = object (b)
  end;

procedure b.foo;
begin
end;

var
  v: c;  { WRONG }

begin
  WriteLn ('failed')
end.
