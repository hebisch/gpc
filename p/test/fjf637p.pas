program fjf637p;

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
  p: PObjectType;

begin
  p := TypeOf (a);
  if p^.Size = 0 then WriteLn ('OK') else WriteLn ('failed')
end.
