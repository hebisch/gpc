{ Overriding a non-iocritical virtual method with an iocritical one
  should give a warning since a virtual call through the parent type
  would miss the iocritical information. }

program fjf826f;

type
  t = object
    constructor i;
    procedure p; virtual;
  end;

type
  u = object (t)
    procedure p; attribute (iocritical); virtual;  { WARN }
  end;

constructor t.i;
begin
end;

procedure t.p;
begin
end;

procedure u.p;
begin
end;

begin
end.
