program fjf637l;

type
  a = abstract object
    procedure foo; abstract;
  end;

  b = object (a)
    constructor i;
    procedure foo; virtual;
  end;

constructor b.i;
begin
end;

procedure b.foo;
begin
end;

var
  v: ^a;

begin
  New (v);  { WRONG }
  WriteLn ('failed')
end.
