{$W no-object-assignment}

program fjf884f;

type
  a = object
    c: Integer;
  end;

  b = object (a)
    d: Integer;
  end;

var
  va: a;
  vb: b;

begin
  vb := va  { WRONG }
end.
