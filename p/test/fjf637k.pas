{$W no-implicit-abstract}

program fjf637k;

type
  a = abstract object
    procedure foo; abstract;
    procedure bar; abstract;
  end;

  b = object (a)
    constructor i;
    procedure foo; virtual;
  end;

  c = object (b)
    procedure bar; virtual;
  end;

constructor b.i;
begin
end;

procedure b.foo;
begin
end;

procedure c.bar;
begin
end;

var
  v: c;

begin
  WriteLn ('OK')
end.
