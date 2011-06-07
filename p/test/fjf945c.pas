program fjf945c;

type
  o = object
  end;

  oo = object (o)
    o: Integer;  { WARN }
  end;

begin
end.
