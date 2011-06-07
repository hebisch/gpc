program fjf637s;

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
  s: SizeType;

begin
  s := SizeOf (a);  { WRONG }
  WriteLn ('failed')
end.
