program Chief51c;

type
  a = abstract object
    procedure p; virtual;
  end;

  b = object (a)  { WARN }
  end;

procedure a.p;
begin
end;

begin
end.
