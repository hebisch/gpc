program fjf637n;

type
  pa = ^a;
  a = abstract object
    procedure foo; abstract;
  end;

  pb = ^b;
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
  v := New (pb);
  WriteLn ('OK')
end.
