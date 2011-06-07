program Chief52a;

type
  a = object
    procedure p;
  end;

  b = object (a)
    constructor a;
    procedure p; virtual;  { WARN }
  end;

procedure a.p;
begin
end;

constructor b.a;
begin
end;

procedure b.p;
begin
end;

begin
end.
