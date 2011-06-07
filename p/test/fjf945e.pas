program fjf945e;

type
  o = object
  end;

  oo = object (o)
  end;

  ooo = object (oo)
    procedure o;  { WARN }
  end;

procedure ooo.o;
begin
end;

begin
end.
