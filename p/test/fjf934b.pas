program fjf934b;

type
  o = abstract object
    procedure a; abstract;
  end;

  oo = object (o)
    constructor Init;
    procedure a; virtual;
  end;

constructor oo.Init;
begin
end;

procedure oo.a;
begin
  inherited a  { WRONG }
end;

begin
end.
