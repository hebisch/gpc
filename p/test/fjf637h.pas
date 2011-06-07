program fjf637h;

type
  a = abstract object
    procedure foo; abstract;
    procedure bar; abstract;
  end;

  b = object (a)
    procedure foo; virtual;
  end;

procedure b.foo;
begin
end;

var
  v: b;  { WRONG }

begin
  WriteLn ('failed')
end.
