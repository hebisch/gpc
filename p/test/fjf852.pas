program fjf852;

type
  a = object
    constructor i;
    procedure p; virtual;
  end;

  b = object (a)
    procedure p (b: Integer); virtual;  { WRONG }
  end;

constructor a.i;
begin
end;

procedure a.p;
begin
end;

procedure b.p (b: Integer);
begin
end;

begin
end.
