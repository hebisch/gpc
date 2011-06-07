program fjf945b;

type
  o = object
  end;

  oo = object (o)
    procedure o;  { WARN }
  end;

procedure oo.o;
begin
end;

begin
end.
