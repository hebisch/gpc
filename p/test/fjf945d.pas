{$borland-pascal}

program fjf945d;

type
  o = object
  end;

  oo = object (o)
    o: Integer;  { WARN }
  end;

begin
end.
