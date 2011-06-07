{$W no-object-assignment}

program fjf884g;

type
  a = object
    c: Integer;
  end;

  b = object
    d: Integer;
  end;

var
  va: a;
  vb: b;

begin
  va := vb  { WRONG }
end.
