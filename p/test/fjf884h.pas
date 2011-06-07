{$W no-object-assignment}

program fjf884h;

type
  a = object
    c: Integer;
  end;

var
  va: a;

begin
  va := 0  { WRONG }
end.
