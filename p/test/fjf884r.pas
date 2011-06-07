{$W no-object-assignment}

program fjf884r;

type
  a = object
  end;

  b = object (a)
    d: Integer;
  end;

var
  va: a;
  vb: b;

begin
  va := vb  { WARN (assignment of object with no fields) }
end.
