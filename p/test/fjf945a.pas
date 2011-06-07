program fjf945a;

type
  o = object
  end;

  oo = object (o)
{$local object-pascal}
    o: Integer;  { WRONG according to OOE draft }
  end;
{$endlocal}

begin
end.
