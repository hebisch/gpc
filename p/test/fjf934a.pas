program fjf934a;

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
  o.a  { WRONG }
end;

begin
end.
